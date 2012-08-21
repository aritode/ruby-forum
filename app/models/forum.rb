class Forum < ActiveRecord::Base
  include Bitfields

  attr_accessible :title, :description, :parent_id, :can_contain_topics, :is_active, :allow_posting, 
                  :display_order, :ancestry, :options, :reply_count, :last_post_id, :last_post_at, 
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
    return Forum.all(:conditions => ['id IN(?)', ids])
  end

  # Returns the most recent post a forum (including sub-forums) has.
  def most_recent_post
    return Topic.first(
      :order      => 'last_post_at DESC', 
      :conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

  # Returns the total number of replies a forum has (including sub-forums).
  def number_of_post
    return Post.count(
      :joins      => [:topic], 
      :conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

  # Returns the total number of topics a forum has (including sub-forums).
  def number_of_topics
    return Topic.count(:conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

end
