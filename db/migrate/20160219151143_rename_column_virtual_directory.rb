class RenameColumnVirtualDirectory < ActiveRecord::Migration
  def change
    rename_column :virtual_files, :virtual_directory_id, :virtual_folder_id
  end
end
