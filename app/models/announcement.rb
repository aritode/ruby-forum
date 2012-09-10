class Announcement < ActiveRecord::Base
  attr_accessible :title, :user_id, :forum_id, :content, :views, :starts_at, :expires_at
  
  has_one :forum, :primary_key => :forum_id, :foreign_key => :id
  has_one :user, :primary_key => :user_id, :foreign_key => :id
  
  validates_presence_of :title, :content

end
