require 'Gitlab'
require_relative 'utils'

config = YAML::load_file('gitlab.yaml')
Gitlab.private_token = config["Gitlab"]["token"]
Gitlab.endpoint =  config["Gitlab"]["endpoint"]

GUEST = 10
MASTER = 40
DESC = "A repository where you will be expected to submit all parts of your coursework"
MODULE = config["module"]
# initialize a new client
# TODO add options for this to be set in config or args
group = "#{MODULE}_mock"
g = Gitlab.client()
cwk_group = ""
begin
	cwk_group = Gitlab.create_group(group, group)
rescue
	cwk_group = Gitlab.group_search(group)[0]
end

staff = []
for member in config["staff"] do
	staff.push(Gitlab.user_search(member)[0])
end

#TODO add better arg parsing and help
if ARGV.length > 0
	action = ARGV[0]
	case action 
	when "-r"
		Utils.remove_members(g, cwk_group, config)
	when "-t"
		Utils.handle_teams(g, config, staff, cwk_group)
	when "-i"
		Utils.handle_individual(g, "Mock_Class_Test_", config, staff, group)
	else
		puts "Unrecognised command"
	end
else
	puts "This script requires an action: r -  removes team members, t - creates teams, i - handles individuals"
end

# YOU
#user = g.user
#puts user.email

# iterate all projects
#projects.auto_paginate do |project|
#	puts project.name
#end
