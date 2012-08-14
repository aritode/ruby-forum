class AddHtmlMarkupToUsergroups < ActiveRecord::Migration
  def change
    add_column :usergroups, :open_tag, :string
    add_column :usergroups, :close_tag, :string
  end
end
