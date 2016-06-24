ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"]||"sqlite3:db/development.db")

class VirtualFolder < ActiveRecord::Base
   has_secure_password
   has_many :virtual_files, dependent: :destroy
   has_many :virtual_folders, dependent: :destroy
   validates :name, presence: true
   validates :name, uniqueness: true , if: :parent?
   
   def parent?
      parent == true
   end
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

def VirtualFolder.file_upload(folder,upload_file,parent)
   folder = VirtualFolder.find(folder)
   parent_folder = VirtualFolder.find(parent)
   tempfile = upload_file[:tempfile]
   
   duplicate = false
   folder.virtual_files.each do |f|
      if f.name == upload_file[:filename]
         duplicate = true
      end
   end
   
   if duplicate
      File.unlink(tempfile)
      return true
   end
   
   parent_folder.size += tempfile.size
   parent_folder.save
   
   if parent_folder.size <= 1073741824
      begin
         file = VirtualFile.create(
            name: upload_file[:filename],
            filetype: File.extname(upload_file[:filename]),
            link: SecureRandom.hex(8).to_s,
            virtual_folder_id: folder.id
            )
      rescue Errno::EEXIST =>e
         @@error = e.message
         retry
      end
        
      if file.valid?
         f = open("./public/uploaded/#{file.link}#{file.filetype}", "w")
         f.write(tempfile.read)
         f.close
      else
         File.unlink(upload_file)
      end
      File.unlink(tempfile)
   else
      parent_folder.size -= tempfile.size
      parent_folder.save
      @@error == "file size is too large"
   end
   return false
end