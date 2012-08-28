class Post < ActiveRecord::Base
  attr_accessible :content, :topic_id, :user_id, :date
  belongs_to :topic
  belongs_to :user 
  
  validates_presence_of :content
  
end
