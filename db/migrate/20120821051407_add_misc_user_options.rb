class AddMiscUserOptions < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string    :membergroupids,                                :after => :usergroup_id
      t.integer   :displaygroupid,  :default => 0,                :after => :membergroupids
      t.string    :title,           :default => "Junior Member",  :after => :displaygroupid
      t.integer   :options,                                       :after => :title
      t.integer   :post_count,      :default => 0,                :after => :options
      t.datetime  :lastpost_at,                                   :after => :post_count
      t.integer   :lastpost_id,                                   :after => :lastpost_at
    end
  end
end
