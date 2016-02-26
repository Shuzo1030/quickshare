class RenameVirtualDirectory < ActiveRecord::Migration
  def change
    rename_table :virtual_directories, :virtual_folders
  end
end
