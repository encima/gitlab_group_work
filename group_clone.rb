require 'Gitlab'
require 'yaml'

config = YAML::load_file('gitlab.yaml')
puts config
source_dir = config["directory"]
group = config["group"]

# set a user private token
Gitlab.private_token = ENV['GITLAB_TOKEN']
Gitlab.endpoint =  config["Gitlab"]["endpoint"]

# initialize a new client
g = Gitlab.client()

# get a user
user = g.user

# get a user's email
puts "Welcome, #{user.email}. Just checking your groups now..."

groups = Gitlab.groups(per_page:5)
groups.auto_paginate do |group|
	if group.name == config["group"]
		puts "#{group.name} found"
		for p in Gitlab.group_projects(group.name)
			puts "Cloning #{p.name}"
			puts p.http_url_to_repo
			begin
				#using exec exits the current process, always use system!
				system("git clone #{p.http_url_to_repo} #{source_dir + p.name}")
			rescue Exception => e
				next
			end
		end
	end
end


