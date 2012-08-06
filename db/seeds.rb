# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Forum.delete_all
Forum.create(:name => "Main Category", :description => "Main Category Description", :options => 2, :display_order => 1)
Forum.create(:name => "Main Forum", :description => "Main Forum Description", :ancestry => "1", :options => 7, :display_order => 1)

puts "Forum data loaded"

# User.delete_all
# User.create(:username => "admin", :email => "admin@example.com", :password_hash => "$2a$10$dedrcVWResU9hugCMlNLd.SM.btnCLQwjSfn/chVbjVgzqgx24usq", :password_salt => "$2a$10$dedrcVWResU9hugCMlNLd.")
# puts "User data loaded"
