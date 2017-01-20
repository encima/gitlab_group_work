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
g = Gitlab.client()
cwk_group = ""
begin
	cwk_group = Gitlab.create_group("#{MODULE}_cwk", "#{MODULE}_cwk")
rescue
	cwk_group = Gitlab.group_search("#{MODULE}_cwk")[0]
end

puts cwk_group.inspect

def get_namespace(path)
	n_id = 0
	return Gitlab.namespaces unless path
	for n in Gitlab.namespaces
		if n.path == path
			n_id = n.id
		end
	end
	n_id
end


# create a repo, add it to cwk group and assign student. Add README file to repo
def add_student(student, cwk_group)
	repo = "#{MODULE}_#{student.username}"
	begin
		Gitlab.add_group_member(cwk_group.id, student.id, GUEST)
	rescue
		puts "Member already exists"
	end
	begin
		proj = Gitlab.create_project(repo, {namespace_id: cwk_group.id})
		Gitlab.add_team_member(proj.id, student.id, MASTER)
		Gitlab.create_file(proj.id, "README", "master", "This is a test file with no useful content", "Initial commit of coursework guidelines")
	rescue
		puts "User already exists in project, or the project does"
		proj = Gitlab.project_search(repo)[0]
	end
	true
end

CSV.foreach(config["students"]) do |row|
	puts row[0]
	member = Gitlab.user_search(row[0])[0]
	#add_student(member, cwk_group)
end



# YOU
user = g.user
puts user.email

# iterate all projects
#projects.auto_paginate do |project|
#	puts project.name
#end
