# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

######################################################################################################
# Forum
######################################################################################################
Forum.delete_all
ActiveRecord::Base.connection.execute("ALTER TABLE forums AUTO_INCREMENT = 1")
Forum.create(:name => "Contractors Talk Forums",                                    :options => 2, :display_order => 1)
Forum.create(:name => "General Discussion",                     :ancestry => "1",   :options => 7, :display_order => 1)
Forum.create(:name => "Introductions",                          :ancestry => "1",   :options => 7, :display_order => 2)
Forum.create(:name => "New Site Feedback & Technical Support",  :ancestry => "1",   :options => 7, :display_order => 3)
Forum.create(:name => "Business Discussion",                                        :options => 6, :display_order => 2)
Forum.create(:name => "Business",                               :ancestry => "5",   :options => 3, :display_order => 1)
Forum.create(:name => "Contractor Licensing",                   :ancestry => "5/6", :options => 7, :display_order => 1)
Forum.create(:name => "File Swap",                              :ancestry => "5/6", :options => 7, :display_order => 2)
Forum.create(:name => "Marketing & Sales",                      :ancestry => "5",   :options => 7, :display_order => 2)
Forum.create(:name => "Technology",                             :ancestry => "5",   :options => 7, :display_order => 3)
puts "Forum data loaded"

######################################################################################################
# Usergroup
######################################################################################################
Usergroup.delete_all
ActiveRecord::Base.connection.execute("ALTER TABLE usergroups AUTO_INCREMENT = 1")
Usergroup.create(:title => "Unregistered / Not Logged In",      :usertitle => "Guest",            :forum_permissions => "262139")
Usergroup.create(:title => "Registered Users",                  :usertitle => "Member",           :forum_permissions => "226299")
Usergroup.create(:title => "Users Awaiting Email Confirmation",                                   :forum_permissions => "11")
Usergroup.create(:title => "(COPPA) Users Awaiting Moderation",                                   :forum_permissions => "11")
Usergroup.create(:title => "Super Moderators",                  :usertitle => "Super Moderator",  :forum_permissions => "262139")
Usergroup.create(:title => "Administrators",                    :usertitle => "Administrator",    :forum_permissions => "262139")
Usergroup.create(:title => "Moderators",                        :usertitle => "Moderator",        :forum_permissions => "262139")
Usergroup.create(:title => "Banned Users",                      :usertitle => "Banned")
puts "Usergroup data loaded"

######################################################################################################
# User
######################################################################################################
ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = 1")
User.delete_all
User.create(:username => "Admin", :email => "admin@escalatemedia.com", :password => "admin", :password_confirmation => "admin")
puts "User data loaded"
