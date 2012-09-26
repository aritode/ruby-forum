class Forum < ActiveRecord::Base
  include Bitfields

  attr_accessible :title, :description, :parent_id, :display_order, :ancestry, :options, :post_count, 
                  :topic_count, :last_post_id, :child_list,
                  # forum permissions
                  :is_forum, :is_active, :is_open
                  
  has_many :topics, :dependent => :destroy
  has_many :announcements, :dependent => :destroy
  
  # each forum has one "last post" object that we render on the forum's index and show page
  has_one :last_post, :class_name => 'Post', :primary_key => :last_post_id, :foreign_key => :id
  
  # includes methods from the "ancestry" gem
  acts_as_tree

  validates_presence_of :title

  # define forum options using bitfields
  bitfield :options, 
    1 => :is_forum,  # is forum if true, category if false
    2 => :is_active, # hidden from forums view if false
    4 => :is_open    # forum can contain topics if true

  # Returns an array of forums based on the ids passed to it. This method will be refactored soon.
  #
  # @parm String  A comma seperated list of forum ids to fetch from the database
  def fetch_forums_by_ids(ids)
    return Forum.all :conditions => ['id IN(?)', ids]
  end

  # Returns the most recent 'post' that's visible to the public. This is only used when we need to 
  # update the forum's "last_post_id" field. E.g. when creating new topcis, posting, deleting, moving, 
  # merging, etc. This method is more efficient than running the query for every forum on the forum's 
  # index page.
  def recent_post
    topic = Topic.where(['forum_id in(?)', (self.child_ids << self.id)])
                 .where(['redirect = ?', 0]) # don't include redirect topics
                 .where(['visible <> ?', 2]) # don't include soft deleted topics
                 .where(['visible <> ?', 0]) # don't include unapproved topics
                 .order("last_post_at DESC")
                 .first
    # return the last post if we found a topic
    if !topic.nil?
      topic.posts.where(['visible <> ?', 2]).last
    end
  end

  # Returns the total number of replies a forum has (including sub-forums). Used on the forum's index
  # and show page.
  def total_posts
    Forum.calculate :sum, :post_count, 
      :select     => :total_post, 
      :conditions => ['id IN(?)', self.child_ids << self.id]
  end

  # Returns the total number of topics a forum has (including sub-forums). Used on the forum's index
  # and show page.
  def total_topics
    Forum.calculate :sum, :topic_count, 
      :select     => :topic_count, 
      :conditions => ['id IN(?)', self.child_ids << self.id]
  end
end
