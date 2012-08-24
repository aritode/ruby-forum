class AddAdminOptionsToTopics < ActiveRecord::Migration
  def change
    # A topic can be placed into "3" types of states.
    #
    #   0 = The topic needs to be approved by a staff member.
    #   1 = Everyone with permissions to see the thread can see it.
    #   2 = Thread was soft deleted by a staff member (only admins can physically remove topics).
    add_column :topics, :visible,   :integer, :default => 1, :after => :user_id

    # True when a thread is open, false when closed
    add_column :topics, :open,      :integer, :default => 1, :after => :visible

    # The thread_id to redirect the user to.
    add_column :topics, :redirect,  :integer, :default => 0, :after => :open

    # The time a thread expires and gets removed from the database (via cron)
    add_column :topics, :expires,   :datetime,               :after => :redirect

    # If "stickied" is true then the thread will appear at the top of the list all the time
    add_column :topics, :stickied,  :integer, :default => 0, :after => :expires
  end
end
