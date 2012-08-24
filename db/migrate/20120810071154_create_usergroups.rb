class CreateUsergroups < ActiveRecord::Migration
  def change
    create_table :usergroups do |t|
      t.string :title
      t.text :description
      t.string :usertitle
      t.integer :forum_permissions

      t.timestamps
    end
  end
end
