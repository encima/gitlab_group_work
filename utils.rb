require 'gitlab'

module Utils 

	GUEST = 10
	MASTER = 40
	DESC = "A repository where you will be expected to submit all parts of your coursework"

	def self.remove_group_member(gl, group, member)
		puts "Removing #{member.username} from #{group.name}"
		begin
			gl.remove_group_member(group.id, member.id)
		rescue 
			puts "Could not remove #{member.username}"
		end
	end 

	def self.remove_group_members(gl, group, config)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		for student in students do
			member = gl.user_search(student[0])[0]
			remove_member(gl, group, member)
		end
	end 

	def get_proj_from_member(gl,member, proj_name)
		
	end 

	def self.remove_team_member(gl, member, project)
		repo = "#{MODULE}_#{project}_#{member.username}"
		puts repo
		begin
			proj = gl.project_search(repo)[0]
			gl.remove_team_member(proj.id, member.id)
			system("git clone #{proj.http_url_to_repo} class_test/#{proj.name}")
		rescue => error
			puts error
			puts "Issue removing member from project"
		end
	end

	def self.remove_team_members(gl, config, project, extra)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		ext_l = config["students_extra"]
		for student in students do
			if (ext_l.include?(student[0]) and extra) or (!ext_l.include?(student[0]) and not extra)
				member = gl.user_search(student[0])[0]
				puts member.inspect 
				remove_team_member(gl, member, project)
			end
		end
	end

	# create a repo, add it to cwk group and assign member. Add README file to repo
	def self.add_member(gl, project, suffix, member, cwk_group, add_to_group, repo)
		repo_name = "#{repo}_#{suffix}"
		puts repo_name
		if add_to_group
			begin
				gl.add_group_member(cwk_group.id, member.id, GUEST)
			rescue
				puts "Member already exists"
			end
		end
		begin
			proj = gl.create_project(repo_name, {namespace_id: cwk_group.id})
			puts "Created #{repo}"
			gl.add_team_member(proj.id, member.id, MASTER)
			#TODO pass readme string to commit
			gl.create_file(proj.id, "README", "master", "Please ONLY commit the app files here. There should only be an app folder in the root of this repo (and a README). Commits before the start of the class test (and after the end) will result in failure", "Initial commit test")
		rescue => error
			puts error
			proj = gl.project_search(repo)[0]
			gl.add_team_member(proj.id, member.id, MASTER)
		end
		true
	end

	def self.handle_individual(gl, config, repo_name, staff, group)
		students = CSV.read(config["students"], headers:true)
		student_keys = students.headers
		for student in students do
			member = gl.user_search(student[0])[0]
			add_member(gl, repo_name, "#{member.username}", member, group, false, repo)
			for s in staff do
				add_member(gl, repo_name, "#{member.username}", s, group, true, repo)
			end
			puts "------"
		end
		true
	end

	def self.handle_groups(gl, config, repo, staff, group)
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
			add_member(gl, student["project"], student["Team"], member, group, false, repo)
			for s in staff do
				add_member(gl, student["project"], student["team"], s, group, true, repo)
			end
			puts "------"
		end
		true
	end 
end
