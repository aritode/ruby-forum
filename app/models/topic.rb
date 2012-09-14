class Topic < ActiveRecord::Base
  attr_accessible :title, :last_poster_id, :last_post_at, :forum_id, :user_id, :views, :replies, 
                  :visible, :open, :redirect, :expires, :sticky

  belongs_to :forum
  belongs_to :user
  
  has_many :posts, :dependent => :destroy
  has_many :topic_reads, :dependent => :destroy
  
  validates_presence_of :title
  
  # Update forum counters and last_post info after a new topic has been created
  after_create do |t|
    if t.redirect == 0 # redirect topics don't count towards stats
      t.forum.update_attributes(
        :topic_count  => self.forum.topic_count + 1,
        :last_post_id => self.forum.recent_post.nil? ? 0 : self.forum.recent_post.id
      )
    end
  end

  # update counters when certain actions have been preformed
  after_update do |t|
    # if the user_id changes, update their post counts
    if t.user_id_changed?
      User.increment_counter :post_count, t.user_id
      User.decrement_counter :post_count, t.user_id_was
    end
  end
  
  # update the forum stats after destroying the object
  after_destroy do |t|
    if t.redirect == 0 # redirect topics don't count towards stats
      t.forum.update_attributes(
        :topic_count  => t.forum.topic_count - 1,
        :last_post_id => t.forum.recent_post.nil? ? 0 : t.forum.recent_post.id
      )
    end

    User.decrement_counter :post_count, t.user_id
  end
end