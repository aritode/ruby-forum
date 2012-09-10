class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      # The title of the announcement
      t.string  :title

      # The user_id of the user posting the announcement
      t.integer :user_id

      # The forum_id that the announcement should reside in
      t.integer :forum_id

      # The content of the announcement
      t.text    :content

      # The number of views the announcement has received
      t.integer :views, :default => 0
      
      # The date when the announcement show be shown
      t.datetime :starts_at

      # The date when the announcement expires
      t.datetime :expires_at

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
