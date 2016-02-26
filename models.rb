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