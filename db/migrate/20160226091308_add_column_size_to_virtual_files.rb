class AddColumnSizeToVirtualFiles < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :size, :integer, default: 0
  end
end
