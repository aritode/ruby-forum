class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      # The title of the forum
      t.string    :title
      
      # The forum's main description
      t.text      :description

      # The link the forum should redirect the user to
      t.string    :link
      
      # The forum's hierarchical data (parent / child forum relationship)
      t.string    :ancestry
      
      # The forum's settings and permissions stored as bitfields
      t.integer   :options

      # The order the forum should be shown within it's tree
      t.integer   :display_order, :default => 0
      
      # The total number of topics a fourm contains (including child forums)
      t.integer   :topic_count,   :default => 0
      
      # The total number of post a fourm contains (including child forums)
      t.integer   :post_count,    :default => 0

      # The id of the last post that was posted in the forum
      t.integer   :last_post_id,  :default => 0
      
      # Rail's update_at and created_at columns
      t.timestamps
    end
    
    add_index :forums, :ancestry
  end
end
