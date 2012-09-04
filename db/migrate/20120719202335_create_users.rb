class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # The username of the account
      t.string    :username

      # The account's email address
      t.string    :email

      # Basic user authentication (will switch to the devise gem soon)
      t.string    :password_hash
      t.string    :password_salt
      
      # The usergroup the user belongs to
      t.integer   :usergroup_id

      # Any addtional usergroup groups the user belongs to
      t.string    :membergroup_ids

      # The usergroup the user wish to display on the forum
      t.integer   :displaygroup_id,  :default => 0

      # The user's title that display's under the post (Administrator, moderator, etc.)
      t.string    :title,            :default => ""
      
      # The users options stored as bitfields
      t.integer   :options
      
      # The total number of post the user has made
      t.integer   :post_count,       :default => 0

      # The date and time the user last visit the site
      t.datetime  :last_visit_at

      # The date and time the user last posted
      t.datetime  :last_post_at

      # The id of the last post the user posted in
      t.integer   :last_post_id

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
