class CreateTableFiles < ActiveRecord::Migration
  def change
    create_table :virtual_directories do |t|
      t.string :name
      t.string :password
      t.string :password_digest,null: false
      t.timestamps null: false
    end
  end
end
