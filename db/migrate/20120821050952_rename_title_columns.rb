class RenameTitleColumns < ActiveRecord::Migration
  def change
    change_table :forums do |t|
      t.rename :name, :title
    end
    change_table :topics do |t|
      t.rename :name, :title
    end
  end
end
