class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      # The title of the post
      t.string   :title

      # The contents of the post (the actual message/comment)
      t.text     :content
      
      # The id of the topic the post belongs to
      t.integer  :topic_id

      # The id of the user who made the post
      t.integer  :user_id

      # The id of the topic being used for staff members to discuss this post
      t.integer  :report_id, :default => 0
      
      # A post can be placed into "4" types of states.
      #
      #   0 = The post needs to be approved by a staff member.
      #   1 = Everyone with permissions to see the post can see it.
      #   2 = Post was soft deleted by a staff member (only admins can physically remove post).
      t.integer  :visible,        :default => 1

      # The poster can choose to display their signature if they want
      t.integer  :show_signature, :default => 1

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
