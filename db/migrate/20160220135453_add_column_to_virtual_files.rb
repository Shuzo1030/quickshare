class AddColumnToVirtualFiles < ActiveRecord::Migration
  def change
    add_column :virtual_files, :filetype, :string
  end
end
