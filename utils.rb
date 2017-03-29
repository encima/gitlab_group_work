require 'Gitlab'

module Utils 
	def self.remove_member(gl, group, member)
		puts "Removing #{member.username} from #{group.name}"
		begin
			gl.remove_group_member(group.id, member.id)
		rescue 
			puts "Could not remove #{member.username}"
		end
	end 

	def self.remove_members(gl, group, config)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		for student in students do
			member = gl.user_search(student[0])[0]
			remove_member(gl, group, member)
		end
	end

	# create a repo, add it to cwk group and assign member. Add README file to repo
	def self.add_member(gl, project, suffix, member, cwk_group, add_to_group)
		repo = "#{MODULE}_#{project}_#{suffix}"
		puts repo
		if add_to_group
			begin
				gl.add_group_member(cwk_group.id, member.id, GUEST)
			rescue
				puts "Member already exists"
			end
		end
		begin
			proj = gl.create_project(repo, {namespace_id: cwk_group.id})
			gl.add_team_member(proj.id, member.id, MASTER)
			#TODO pass readme string to commit
			gl.create_file(proj.id, "README", "master", "This is a test file with no useful content", "Initial commit test")
		rescue
			puts "User already exists in project, or the project does"
			proj = gl.project_search(repo)[0]
			gl.add_team_member(proj.id, member.id, MASTER)
		end
		true
	end

	def self.handle_individual(gl, repo_name, config, staff, group)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		for student in students do
			member = gl.user_search(student[0])[0]
			puts member.inspect
			add_member(gl, repo_name, "#{member.username}", member, group, false)
			for s in staff do
				add_member(gl, repo_name, "#{member.username}", s, group, true)
			end
			puts "------"
		end
		true
	end

	def self.handle_teams(gl, config, staff, group)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		team = 0
		for student in students do
			puts student["Team"]
			if student["Team"] != team
				team = student["Team"]
				puts "Changing team to #{team}"
			end
			member = gl.user_search(student[0])[0]
			puts member.inspect
			add_member(student["project"], student["Team"], member, group, false)
			for s in staff do
				add_member(student["project"], student["team"], s, group, true)
			end
			puts "------"
		end
		true
	end 
end
