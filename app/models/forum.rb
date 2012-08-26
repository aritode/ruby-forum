class Forum < ActiveRecord::Base
  include Bitfields

  attr_accessible :title, :description, :parent_id, :can_contain_topics, :is_active, :allow_posting, 
                  :display_order, :ancestry, :options, :post_count, :last_post_id, :last_post_at, 
                  :last_post_user_id, :last_topic_at, :last_topic_id, :last_topic_title
  
  has_many :topics, :dependent => :destroy

  # includes methods from the "ancestry" gem
  acts_as_tree

  validates_presence_of :title

  # define the forums options here using bitfields
  bitfield :options, 
    1 => :can_contain_topics,
    2 => :is_active, 
    4 => :allow_posting

  # Returns an array of forums based on the ids passed to it
  #
  # @parm String  A comma seperated list of forum ids to fetch from the database
  def fetch_forums_by_ids(ids)
    return Forum.all :conditions => ['id IN(?)', ids]
  end

  # Returns the last topic a forum has (including sub-forums)
  def last_topic
    Topic.first(
      :order      => 'last_post_at DESC', 
      :conditions => "forum_id in(#{(self.child_ids << self.id).join(",")}) and redirect = 0")
  end
  
  # Returns the total number of replies a forum has (including sub-forums).
  def total_posts
    Forum.calculate :sum, :post_count, 
      :select     => :total_post, 
      :conditions => ['id IN(?)', self.child_ids << self.id]
  end

  # Returns the total number of topics a forum has (including sub-forums).
  def total_topics
    Forum.calculate :sum, :topic_count, 
      :select     => :topic_count, 
      :conditions => ['id IN(?)', self.child_ids << self.id]
  end
end
