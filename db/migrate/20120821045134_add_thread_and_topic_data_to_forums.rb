class AddThreadAndTopicDataToForums < ActiveRecord::Migration
  def change
    ## Basic information
    add_column :forums, :link, :string, :after => :description
    
    ## Forum counters
    add_column :forums, :topic_count, :integer, :default => 0, :after => :display_order
    add_column :forums, :reply_count, :integer, :default => 0, :after => :topic_count
    
    ## Last topic and post data
    add_column :forums, :last_post_id,      :integer, :after => :reply_count
    add_column :forums, :last_post_at,      :integer, :after => :last_post_id
    add_column :forums, :last_post_user_id, :integer, :after => :last_post_at
    add_column :forums, :last_topic_at,     :integer, :after => :last_post_user_id
    add_column :forums, :last_topic_id,     :integer, :after => :last_topic_at
    add_column :forums, :last_topic_title,  :string,  :after => :last_topic_id
  end
end
