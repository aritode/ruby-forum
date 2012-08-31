class CreateTopicReads < ActiveRecord::Migration
  def change
    create_table :topic_reads do |t|
      # The id of the topic that's been marked as read
      t.integer  :topic_id

      # The id of the user who read the topic
      t.integer  :user_id

      # The date and time the user read the topic
      t.datetime :date

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
