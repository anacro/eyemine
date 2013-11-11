class CreateIosNotifications < ActiveRecord::Migration
  def change
    create_table :ios_notifications do |t|

      t.integer :user_id

      t.string :device_token, :limit => 255

      t.string :alert, :limit => 255

      t.datetime :created_on

      t.integer :issue_id

    end

  end
end
