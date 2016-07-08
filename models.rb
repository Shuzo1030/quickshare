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

def VirtualFolder.folder_request(depth)
   requested_folder = VirtualFolder.find(depth)
   @@folder = requested_folder
   @@childfolders = requested_folder.virtual_folders
   @@files = requested_folder.virtual_files
end
   
def VirtualFolder.folder_delete(delete)
   delete_folder = VirtualFolder.find(delete)
   delete_files = delete_folder.virtual_files
   delete_files.each do |delete_file|
      File.unlink("./public/uploaded/#{delete_file.link}#{delete_file.filetype}")
   end
   delete_folder.destroy
end

def VirtualFolder.file_upload(folder_id,file)
   folder = VirtualFolder.find(folder)
   root_folder = VirtualFolder.find(folder.root_id)
   tempfile = file[:tempfile]
   
   root_folder.size += tempfile.size
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