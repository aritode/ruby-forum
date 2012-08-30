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
Forum.create(:title => "Contractors Talk Forums",                                    :options => 2, :display_order => 1)
Forum.create(:title => "General Discussion",                     :ancestry => "1",   :options => 7, :display_order => 1)
Forum.create(:title => "Introductions",                          :ancestry => "1",   :options => 7, :display_order => 2)
Forum.create(:title => "New Site Feedback & Technical Support",  :ancestry => "1",   :options => 7, :display_order => 3)
Forum.create(:title => "Business Discussion",                                        :options => 6, :display_order => 2)
Forum.create(:title => "Business",                               :ancestry => "5",   :options => 3, :display_order => 1)
Forum.create(:title => "Contractor Licensing",                   :ancestry => "5/6", :options => 7, :display_order => 1)
Forum.create(:title => "File Swap",                              :ancestry => "5/6", :options => 7, :display_order => 2)
Forum.create(:title => "Marketing & Sales",                      :ancestry => "5",   :options => 7, :display_order => 2)
Forum.create(:title => "Technology",                             :ancestry => "5",   :options => 7, :display_order => 3)
puts "Forum data loaded"

# Topic.delete_all
# ActiveRecord::Base.connection.execute("ALTER TABLE topics AUTO_INCREMENT = 1")
# Topic.create(:title => "Test Topic 1", :user_id => 1, :forum_id => 2, :replies => 1, :last_poster_id => 2, :last_post_at => "2012-08-30 07:18:46")
# puts "Topic data loaded"

# Post.delete_all
# ActiveRecord::Base.connection.execute("ALTER TABLE posts AUTO_INCREMENT = 1")
# Post.create(:topic_id => 1, :content => "This is a topic 1!", :user_id => 1, :date => "2012-08-30 07:18:23")
# Post.create(:topic_id => 1, :content => "This is a reply 1!", :user_id => 2, :date => "2012-08-30 07:25:46")
# puts "Post data loaded"

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
User.create(:username => "Admin", :email => "admin@escalatemedia.com", :password => "admin", :password_confirmation => "admin", :usergroup_id => "6")
User.create(:username => "Kenny", :email => "ken@escalatemedia.com", :password => "kenny", :password_confirmation => "kenny", :usergroup_id => "6")
puts "User data loaded"
