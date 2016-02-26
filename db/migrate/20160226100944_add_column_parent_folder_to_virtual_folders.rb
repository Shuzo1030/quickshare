class AddColumnParentFolderToVirtualFolders < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :virtual_folder_id, :integer
  end
end
