class Forum < ActiveRecord::Base
  attr_accessible :name, :description, :parent_id, :can_contain_topics, :is_active, :allow_posting, :display_order, :ancestry, :options
  has_many :topics, :dependent => :destroy

  # includes methods from the "ancestry" gem
  acts_as_tree

  validates_presence_of :name

  # define the forums options here using bitfields
  include Bitfields
  bitfield :options, 
    1 => :can_contain_topics,
    2 => :is_active, 
    4 => :allow_posting

  # temp function to fetch forums
  def fetch_child_forums(ids)
    return Forum.all(:conditions => ['id IN(?)', ids])
  end

  # returns the most recent post a forum (including sub-forums) has.
  def most_recent_post
    return Topic.first(
      :order      => 'last_post_at DESC', 
      :conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

  # returns the total number of replies a forum (including sub-forums) has.
  def number_of_post
    return Post.count(
      :joins      => [:topic], 
      :conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

  # returns the total number of topics a forum (including sub-forums) has.
  def number_of_topics
    return Topic.count(:conditions => ['forum_id IN(?)', self.child_ids << self.id])
  end

end
