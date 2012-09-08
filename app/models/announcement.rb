class Announcement < ActiveRecord::Base
  attr_accessible :title, :user_id, :forum_id, :content, :views, :starts_at, :expires_at
  
  has_one :forum
  has_one :user
end
