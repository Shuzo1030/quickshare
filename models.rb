ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"]||"sqlite3:db/development.db")

class VirtualFolder < ActiveRecord::Base
   has_secure_password
   has_many :virtual_files, dependent: :destroy
   
   has_many :children, dependent: :destroy, class_name: "VirtualFolder", foreign_key: "virtual_folder_id"
   belongs_to :parent, class_name: "VirtualFolder", foreign_key: "virtual_folder_id"
   
   validates :name, presence: true
   validates :name, uniqueness: true , if: :parent?
   
   def delete_folder
      files = self.virtual_files
      files.each do |file|
         File.unlink("./public/uploaded/#{file.link}#{file.filetype}")
      end
      self.destroy
   end
   
   def root?
      return  id == root_id
   end
   
   def upload(file)
      root_folder = VirtualFolder.find(self.root_id)
      tempfile = file[:tempfile]
      
      root_folder.size += File.stat(tempfile).size
      root_folder.save
      
      if root_folder.size <= 1073741824
         begin
            file = VirtualFile.create(
               name: file[:filename],
               filetype: File.extname(file[:filename]),
               link: SecureRandom.hex(8).to_s,
               virtual_folder_id: self.id
               )
         rescue Errno::EEXIST
            retry
         end
         
         if file.valid?
            f = open("./public/uploaded/#{file.link}#{file.filetype}", "w")
            f.write(tempfile.read)
            f.close
         else
            File.unlink(file)
         end
         File.unlink(tempfile)
      else
         root_folder.size -= tempfile.size
         root_folder.save
         @@error == "file size is too large"
      end
      
      return file
   end
   
   def add_zip(zip,link)
      files = self.virtual_files
      files.each do |file|
         zip.add("#{link}/#{file.name.encode("Shift_JIS")}","./public/uploaded/#{file.link}#{file.filetype}")
      end
      children = self.children
      unless children.empty?
         children.each do |child|
            link = link + "/#{child.name.encode("Shift_JIS")}"
            zip.mkdir("#{link}")
            child.add_zip(zip,link)
         end
      end
   end
   
   def dir_list(list)
      if parent.nil?
         return list
      else
         list.push(parent)
         parent.dir_list(list)
      end
   end
end

class VirtualFile < ActiveRecord::Base
   belongs_to :virtual_folder
   validates :link, uniqueness: true
end