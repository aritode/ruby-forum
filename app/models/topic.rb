class Topic < ActiveRecord::Base
  attr_accessible :title, :last_poster_id, :last_post_at, :forum_id, :user_id, :views, :replies, 
                  :visible, :open, :redirect, :expires, :stickied

  belongs_to :forum
  belongs_to :user
  has_many :posts, :dependent => :destroy
  
  
  validates_presence_of :title
  
end
