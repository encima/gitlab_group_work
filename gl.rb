require 'Gitlab'
#require 'CSV'
config = YAML::load_file('gitlab.yaml')
Gitlab.private_token = config["Gitlab"]["token"]
Gitlab.endpoint =  config["Gitlab"]["endpoint"]

GUEST = 10
MASTER = 40
DESC = "A repository where you will be expected to submit all parts of your coursework"
MODULE = config["module"]
# initialize a new client
group = "#{MODULE}_project"
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
puts staff



# create a repo, add it to cwk group and assign member. Add README file to repo
def add_member(project, team, member, cwk_group)
	repo = "#{MODULE}_#{project}_Team#{team}"
	begin
		Gitlab.add_group_member(cwk_group.id, member.id, GUEST)
	rescue
		puts "Member already exists"
	end
	begin
		proj = Gitlab.create_project(repo, {namespace_id: cwk_group.id})
		Gitlab.add_team_member(proj.id, member.id, MASTER)
		Gitlab.create_file(proj.id, "README", "master", "This is a test file with no useful content", "Initial commit test")
	rescue
		puts "User already exists in project, or the project does"
		proj = Gitlab.project_search(repo)[0]
		Gitlab.add_team_member(proj.id, member.id, MASTER)
	end
	true
end

def handle_teams(team, config, staff, group)
	students = CSV.read(config["students"], headers:true)
	student_keys = students.headers
	for student in students do
		puts student["Team"]
		if student["Team"] != team
			team = student["Team"]
			puts "Changing team to #{team}"
			for s in staff do
				add_member(student["Project"], student["Team"], s, group)
			end
		end
		puts student["Project"]
		member = Gitlab.user_search(student[0])[0]
		puts member.inspect
		add_member(student["Project"], student["Team"], member)
		puts "------"
	end
	true
end

handle_teams(0, config, staff, cwk_group)

# YOU
user = g.user
puts user.email

# iterate all projects
#projects.auto_paginate do |project|
#	puts project.name
#end
