class AddColumnRootIdToVirtualFolders < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :root_id, :integer
  end
end
