class AddColumnToVirtualFolders < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :admin_pass , :string, default: nil
  end
end
