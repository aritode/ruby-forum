class AddOptionsToForum < ActiveRecord::Migration
  def change
    add_column :forums, :options, :integer, :default => 0, :null => false
  end
end
