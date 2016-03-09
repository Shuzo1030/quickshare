class AddColumnsToVirtualFolders < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :parent, :boolean, default: false
    add_column :virtual_folders, :expire, :date
  end
end
