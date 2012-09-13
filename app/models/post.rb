class Post < ActiveRecord::Base
  attr_accessible :title, :content, :topic_id, :user_id, :visible

  belongs_to :topic
  belongs_to :user 
  
  has_one :report_topic, :class_name => 'Topic', :primary_key => :report_id, :foreign_key => :id

  validates_presence_of :content
  
  # Update the forum stats and last post information after a post has been made
  after_create do |p|
    # update the user's post count and last_post info
    p.user.update_attributes(
      :post_count   => p.user.post_count + 1,
      :last_post_at => Time.now,
      :last_post_id => self.id
    )

    # update the topic and forum's last_post info
    p.topic.update_attribute(:last_post_at, Time.now)
    p.topic.forum.update_attribute(:last_post_id, 
                              p.topic.forum.recent_post.nil? ? 0 : p.topic.forum.recent_post.id)

    # if this isn't the first post of the topic, update the topic and forum's post counters
    if p.topic.views > 0
      p.topic.update_attribute(:replies, p.topic.replies + 1)
      p.topic.forum.update_attribute(:post_count, p.topic.forum.post_count + 1)
    end
  end
end