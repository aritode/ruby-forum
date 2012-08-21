class AddViewsAndRepliesToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :views,   :integer, :default => 0, :after => :user_id
    add_column :topics, :replies, :integer, :default => 0, :after => :views
  end
end
