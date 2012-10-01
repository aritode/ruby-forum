class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      # The title of the topic
      t.string  :title

      # The id of the user who created the topic
      t.integer  :user_id

      # The id of the forum the topic lives in
      t.integer  :forum_id

      # A topic can be placed into "3" types of states.
      #
      #   0 = The topic needs to be approved by a staff member.
      #   1 = Everyone with permissions to see the topic can see it.
      #   2 = Topic was soft deleted by a staff member (only admins can physically remove topics).
      t.integer  :visible,   :default => 1

      # True when a topic is open, false when closed
      t.integer  :open,      :default => 1

      # If "stickied" is true then the topic will appear at the top of the list all the time
      t.integer  :sticky,    :default => 0

      # The total number of views a topic has
      t.integer  :views,     :default => 0

      # The total number of replies a topic has
      t.integer  :replies,   :default => 0

      # The topic_id to redirect the user to.
      t.integer  :redirect,  :default => 0

      # The time a topic expires and gets removed from the database (via cron)
      t.datetime :expires

      # The post id of the last post made in the topic
      t.integer :last_post_id

      # The date and time of the user who last posted in the topic
      t.datetime :last_post_at

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
