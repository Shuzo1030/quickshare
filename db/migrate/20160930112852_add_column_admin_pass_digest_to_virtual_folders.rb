class AddColumnAdminPassDigestToVirtualFolders < ActiveRecord::Migration
  def change
    add_column :virtual_folders, :admin_pass_digest, :string, default:nil
  end
end
