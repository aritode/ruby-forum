class AddDisplayOrderToForums < ActiveRecord::Migration
  def change
    add_column :forums, :display_order, :integer, :default => 0
  end
end
