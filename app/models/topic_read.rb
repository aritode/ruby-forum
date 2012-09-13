class TopicRead < ActiveRecord::Base
  attr_accessible :topic_id, :user_id
  belongs_to :topic
  belongs_to :user
  
  # returns the topic read object for specified user
  scope :by_user, lambda { |id| { :conditions => ["user_id = ?", id] }}
end
