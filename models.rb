ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"]||"sqlite3:db/development.db")

class VirtualFolder < ActiveRecord::Base
   has_secure_password
   has_many :virtual_files, dependent: :destroy
   
   has_many :children, dependent: :destroy, class_name: "VirtualFolder", foreign_key: "virtual_folder_id"
   belongs_to :parent, class_name: "VirtualFolder"
   
   validates :name, presence: true
   validates :name, uniqueness: true , if: :parent?
   
   
end

class VirtualFile < ActiveRecord::Base
   belongs_to :virtual_folder
   validates :link, uniqueness: true
end
   
def VirtualFolder.folder_delete(folder)
   files = folder.virtual_files
   files.each do |delete_file|
      File.unlink("./public/uploaded/#{delete_file.link}#{delete_file.filetype}")
   end
   folder.destroy
end

def VirtualFolder.upload_file(folder_id,file)
   folder = VirtualFolder.find(folder_id)
   root_folder = VirtualFolder.find(folder.root_id)
   tempfile = file[:tempfile]
   
   root_folder.size += File.stat(tempfile).size
   root_folder.save
   
   if root_folder.size <= 1073741824
      begin
         file = VirtualFile.create(
            name: file[:filename],
            filetype: File.extname(file[:filename]),
            link: SecureRandom.hex(8).to_s,
            virtual_folder_id: folder.id
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
end

def VirtualFolder.root?(folder)
   if folder.id = folder.root_id
      return true
   else
      return false
   end
end

def VirtualFolder.add_zip(zip,folder,link)
   files = folder.virtual_files
   files.each do |file|
      zip.add("#{link}/#{file.name.encode("Shift_JIS")}","./public/uploaded/#{file.link}#{file.filetype}")
   end
   folders = folder.children
   unless folders.empty?
      folders.each do |child|
         link = link + "/#{child.name.encode("Shift_JIS")}"
         zip.mkdir("#{link}")
         VirtualFolder.add_zip(zip,child,link)
      end
   end
end