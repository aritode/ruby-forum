class CreateUsergroups < ActiveRecord::Migration
  def change
    create_table :usergroups do |t|
      # The title of the usergroup
      t.string  :title

      # The usergroup's description
      t.text    :description

      # The user title to set all users in this group to
      t.string  :usertitle

      # The groups forum permissions using bitfields
      t.integer :forum_permissions

      # The HTML open tag to use for username markup
      t.string  :open_tag

      # The HTML close tag to use for username markup
      t.string  :close_tag

      # Rail's update_at and created_at columns
      t.timestamps
    end
  end
end
