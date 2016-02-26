class CreateVirtualFiles < ActiveRecord::Migration
  def change
    create_table :virtual_files do |t|
      t.string :name
      t.string :link
      t.references :virtual_directory
      t.timestamps null: false
    end
  end
end
