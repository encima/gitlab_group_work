require 'Gitlab'
require 'yaml'

config = YAML::load_file('gitlab.yaml')
puts config
source_dir = config["directory"]
MODULE = config["module"]
group = "#{MODULE}_project"

# set a user private token
Gitlab.private_token = config["Gitlab"]["token"]
Gitlab.endpoint =  config["Gitlab"]["endpoint"]

# initialize a new client
g = Gitlab.client()

# get a user
user = g.user

# get a user's email
puts "Welcome, #{user.email}. Just checking your groups now..."

# groups = Gitlab.groups(per_page:5)
# groups.auto_paginate do |group|
# 	if group.name == config["group"]
# 		puts "#{group.name} found"
for p in Gitlab.group_projects(group)
	puts "Inspecting #{p.name}"
	puts "URL: " + p.http_url_to_repo
	begin
		#using exec exits the current process, always use system!
		system("gitinspector -HTlrm #{p.http_url_to_repo}")
	rescue Exception => e
		next
	end
	puts "------------------"
end
# 	end
# end


