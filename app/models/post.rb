class Post < ActiveRecord::Base
  attr_accessible :title, :content, :topic_id, :user_id, :visible

  belongs_to :topic
  belongs_to :user 
  
  # if a post gets reported there will be a new staff topic associated with it called "report_topic"
  has_one :report_topic, :class_name => 'Topic', :primary_key => :report_id, :foreign_key => :id

  validates_presence_of :content
  
  # update the counters and last post details after a post is created
  after_create do |p|
    # first posts don't count towards the post/reply counters, so we skip it
    if p.topic.posts.length > 1
      p.topic.update_attribute(:replies, p.topic.replies + 1)
      p.topic.forum.update_attribute(:post_count, p.topic.forum.post_count + 1)
      rebuild_recent_post
    end

    p.user.update_attribute(:post_count, p.user.post_count + 1)
    p.topic.update_attribute(:last_post_at, Time.now)
  end

  # update counters when certain actions have been preformed, E.g. when a post is "soft-deleted", etc.
  after_update do |p|
    # if soft-deleting or unappoving
    if (p.visible_was == 1 and p.visible == 2) or (p.visible_was == 1 and p.visible == 0)
      decrement_posts_stats
    end
    
    # if undeleting or approving
    if (p.visible_was == 2 and p.visible == 1) or (p.visible_was == 0 and p.visible == 1)
      increment_posts_stats
    end
    
    # if the user_id changes, update their post counts
    if p.user_id_changed?
      User.increment_counter :post_count, p.user_id
      User.decrement_counter :post_count, p.user_id_was
    end
    
    rebuild_recent_post
  end
  
  # update stats and last post info when before a post is destroyed
  before_destroy :decrement_posts_stats
  after_destroy  :rebuild_recent_post
  
private
  # quickly increment all post stats
  def increment_posts_stats
    # the first post don't count towards counters, so we skip it
    if self.topic.posts.length > 1
      self.topic.forum.update_attribute(:post_count, self.topic.forum.post_count + 1)
      self.topic.update_attribute(:replies, self.topic.replies + 1)
      self.user.update_attribute(:post_count, self.user.post_count + 1)
    end
  end

  # quickly decrement all post stats
  def decrement_posts_stats
    # first post don't count towards counters, but allow merged post (visible = 3)
    if self.topic.posts.length > 1
      self.topic.forum.update_attribute(:post_count, self.topic.forum.post_count - 1)
      self.topic.update_attribute(:replies, self.topic.replies - 1)
      self.user.update_attribute(:post_count, self.user.post_count - 1)
    end
  end

  # rebuild the forum's recent post info
  def rebuild_recent_post
    self.topic.forum.update_attribute(
      :last_post_id, self.topic.forum.recent_post.nil? ? 0 : self.topic.forum.recent_post.id
    )
  end
end