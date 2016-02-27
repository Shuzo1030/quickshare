ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"]||"sqlite3:db/development.db")

class VirtualFolder < ActiveRecord::Base
   has_secure_password
   has_many :virtual_files, dependent: :destroy
   has_many :virtual_folders, dependent: :destroy
   validates :name, uniqueness: true, presence: true
end

class VirtualFile < ActiveRecord::Base
   belongs_to :virtual_folder
   validates :link, uniqueness: true
end

class FileManager
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
      File.unlink("./public/#{delete_file.link}#{delete_file.filetype}")
   end
   delete_folder.destroy
end

def VirtualFolder.file_upload(folder,upload_file)
   folder = VirtualFolder.find(folder)
   unless upload_file
      redirect back
   end
   tempfile = upload_file[:tempfile]
   folder.size += tempfile.size
   if folder.size <= 1073741824
      begin
         file = VirtualFile.create(
            name: upload_file[:filename],
               filetype: File.extname(upload_file[:filename]),
               link: SecureRandom.hex(8).to_s,
               virtual_folder_id: folder.id
            )
      rescue Errno::EEXIST
         retry
      end
        
      if file.valid?
         f = open("./public/#{file.link}#{file.filetype}", "w")
         f.write(tempfile.read)
         f.close
      else
         File.unlink(upload_file)
      end
      File.unlink(tempfile)
   end
end

def FileManager.deleteall(target)
  if FileTest.directory?(target) then  # ディレクトリかどうかを判別
    Dir.foreach(target) do |file|    # 中身を一覧
      next if /^\.+$/ =~ file           # 上位ディレクトリと自身を対象から外す
      deleteall(target.sub(/\/+$/,"")+"/"+file)
    end
    Dir.rmdir(target) rescue ""        # 中身が空になったディレクトリを削除
  else
    File.delete(target)                # ディレクトリでなければ削除
  end
  p "delete successful"
end