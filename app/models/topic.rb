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

  # updates counters when certain actions have been preformed
  after_update do |t|
    # if the topic get's a new author
    if t.user_id_changed?
      User.increment_counter :post_count, t.user_id
      User.decrement_counter :post_count, t.user_id_was
    end
    
    # if the topic changes to a redirect topic
    if t.redirect_changed?
      Forum.decrement_counter :topic_count, t.forum_id
    end
    
    # if the topic was moved to a new forum
    if t.forum_id_changed?
      # only update if the topic is visible
      if t.visible == 1
        # update the old forum
        old_forum = Forum.find(t.forum_id_was)
        old_forum.update_attributes(
          :topic_count  => old_forum.topic_count - 1,
          :post_count   => old_forum.post_count  - t.replies,
          :last_post_id => old_forum.recent_post.nil? ? 0 : old_forum.recent_post.id
        )
        
        # update the new forum
        t.forum.update_attributes(
          :topic_count  => t.forum.topic_count + 1,
          :post_count   => t.forum.post_count  + t.replies,
          :last_post_id => t.forum.recent_post.nil? ? 0 : t.forum.recent_post.id
        )

        # update all parent forum's last_post_ids for the old and new forum
        if !old_forum.ancestors.empty?  
          for ancestor in old_forum.ancestors
            ancestor.last_post_id = ancestor.recent_post.nil? ? 0 : ancestor.recent_post.id
            ancestor.save
          end
        end
        if !t.forum.ancestors.empty?  
          for ancestor in t.forum.ancestors
            ancestor.last_post_id = ancestor.recent_post.nil? ? 0 : ancestor.recent_post.id
            ancestor.save
          end
        end
      end
    end

    # if soft-deleting or unappoving
    if (t.visible_was == 1 and t.visible == 2) or (t.visible_was == 1 and t.visible == 0)
      # update forum stats
      t.forum.update_attributes(
        :topic_count  => t.forum.topic_count - 1,
        :post_count   => t.forum.post_count  - t.replies,
        :last_post_id => t.forum.recent_post.nil? ? 0 : t.forum.recent_post.id
      )

      # update all the users post count
      for post in t.posts.each
        User.decrement_counter :post_count, post.user_id
      end
    end

    # if undeleting or approving
    if (t.visible_was == 2 and t.visible == 1) or (t.visible_was == 0 and t.visible == 1)
      # update forum stats
      t.forum.update_attributes(
        :topic_count  => t.forum.topic_count + 1,
        :post_count   => t.forum.post_count  + t.replies,
        :last_post_id => t.forum.recent_post.nil? ? 0 : t.forum.recent_post.id
      )

      # update all the users post count
      for post in t.posts.each
        User.increment_counter :post_count, post.user_id
      end
    end
  end
  
  # update the forum stats after destroying the object
  after_destroy do |t|
    if t.redirect == 0 # redirect topics don't count towards stats
      t.forum.update_attributes(
        :topic_count  => t.forum.topic_count - 1,
        :last_post_id => t.forum.recent_post.nil? ? 0 : t.forum.recent_post.id
      )

      User.decrement_counter :post_count, t.user_id
    end
  end
end