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
	
	branches = Gitlab.branches(p.id)
	directory_name = "reports/#{p.name}"
	Dir.mkdir(directory_name) unless File.exists?(directory_name)
	system("git clone #{p.http_url_to_repo} repos/#{p.name}")
	for b in branches
		begin
			puts "Branch: " + b.name
			system("cd repos/#{p.name}; git fetch --all; git checkout #{b.name}")
			branch_name = b.name.gsub! '/', '_'
			system("cd repos/#{p.name}; gitinspector --since=1.week.ago -F html -HTlrm  > ../../reports/#{p.name}/#{b.name}.html")
			system("cd repos/#{p.name}; git standup -f -m 8 -a \"all\" -d 7  > ../../reports/#{p.name}/#{p.name}.txt")
		#using exec exits the current process, always use system!
			# system("gitinspector --since=1.week.ago -F html -HTlrm -b #{b.name} #{p.http_url_to_repo} > reports/#{p.name}/#{b.name}.html")
		rescue Exception => e
			next
		end
	end
	puts "------------------"
end
# 	end
# end


