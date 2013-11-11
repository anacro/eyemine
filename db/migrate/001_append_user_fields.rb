class AppendUserFields < ActiveRecord::Migration
  
  def self.up
    add_column :users, :os, :string, :limit => 20
    add_column :users, :udid, :string, :limit => 50
    add_column :users, :mobile_key, :string, :limit => 255
    add_column :users, :mobile_status, :tinyint, :default => 0
    add_column :users, :mobile_last_login_on, :datetime
    add_column :users, :login_err_count, :tinyint, :default => 0
    add_column :users, :grant_push, :boolean, :default => false, :null => false
    add_column :users, :sound_on_off, :boolean, :default => false, :null => false
  end

  def self.down    
    remove_column :os
    remove_column :udid
    remove_column :mobile_key
    remove_column :mobile_status
    remove_column :mobile_last_login_on
    remove_column :login_err_count
    remove_column :grant_push
    remove_column :sound_on_off    
  end
end
