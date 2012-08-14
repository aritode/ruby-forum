class AddUsergroupidToUser < ActiveRecord::Migration
  def change
    add_column :users, :usergroup_id, :integer
  end
end
