# rebuild the forums cache
def build_forum_cache
  forums  = {}
  parents = Forum.all(:conditions => "ancestry is null", :order => "ancestry ASC, display_order ASC")
  parents.each do |parent|
    forums = forums.merge({parent => parent.descendants.arrange(:order => :display_order)})
  end
  Rails.cache.write 'forums', forums
end

# Forum
Forum.delete_all
ActiveRecord::Base.connection.execute("ALTER TABLE forums AUTO_INCREMENT = 1")
Forum.create(:title => "Contractors Talk Forums",                                    :options => 2, :display_order => 1, :child_list => "2/3/4")
Forum.create(:title => "General Discussion",                     :ancestry => "1",   :options => 7, :display_order => 1)
Forum.create(:title => "Introductions",                          :ancestry => "1",   :options => 7, :display_order => 2)
Forum.create(:title => "New Site Feedback & Technical Support",  :ancestry => "1",   :options => 7, :display_order => 3)
Forum.create(:title => "Business Discussion",                                        :options => 6, :display_order => 2, :child_list => "6/9/10/7/8")
Forum.create(:title => "Business",                               :ancestry => "5",   :options => 3, :display_order => 1, :child_list => "7/8")
Forum.create(:title => "Contractor Licensing",                   :ancestry => "5/6", :options => 7, :display_order => 1)
Forum.create(:title => "File Swap",                              :ancestry => "5/6", :options => 7, :display_order => 2)
Forum.create(:title => "Marketing & Sales",                      :ancestry => "5",   :options => 7, :display_order => 2)
Forum.create(:title => "Technology",                             :ancestry => "5",   :options => 7, :display_order => 3)
build_forum_cache
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
User.create(:username => "Admin", :email => "admin@escalatemedia.com", :password => "admin", :password_confirmation => "admin", :usergroup_id => "6", :last_visit_at => Time.now)
User.create(:username => "Kenny", :email => "ken@escalatemedia.com", :password => "kenny", :password_confirmation => "kenny", :usergroup_id => "6", :last_visit_at => Time.now)
puts "User data loaded"


