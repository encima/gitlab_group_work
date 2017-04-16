require 'arg-parser'
require 'gitlab'
require_relative 'utils'

class GLArgs 

	include ArgParser::DSL

	
	purpose <<-EOT
		test for arg parser
	EOT

	positional_arg :Action, 'Create or remove projects'
	#flag_arg :extra, 'flag'
	keyword_arg :target, 'Teams or individuals', short_key: '-t',	default: 'TEAMS'
	keyword_arg :extra_time, 'Include or exclude extra time students', short_key: '-e', default: false
	keyword_arg :module, 'Module code', short_key: '-m', default: 'CM6122'
	keyword_arg :group, 'Group name', short_key: '-h', default: '_Coursework'
	keyword_arg :repo, 'Repo name', short_key: '-r', default: '_cwk'
	keyword_arg :config, 'Path to config file', short_key: '-c', default: 'gitlab.yaml'
	keyword_arg :dry_run, 'Do not run with active connection to gitlab (not implemented)', default: false 

	def run

		if opts = parse_arguments
			config= YAML::load_file(opts.config)
			Gitlab.private_token = ENV['GITLAB_TOKEN']
			Gitlab.endpoint =  config["Gitlab"]["endpoint"]
			g = Gitlab.client()
			module_code = opts.module 
			group_suffix = opts.group
			group = "#{module_code}#{group_suffix}"
			cwk_group = ""
			begin
				cwk_group = Gitlab.create_group(group, group)
			rescue
				cwk_group = Gitlab.group_search(group)[0]
			end
			puts cwk_group.id

			repo = "#{module_code}#{opts.repo}"

			staff = []
			for member in config["staff"] do
				staff.push(Gitlab.user_search(member)[0])
			end
			case opts.action
				when 'CREATE'
					case opts.target 
						when 'TEAMS'
							Utils.handle_groups(g, config, repo, staff, cwk_group)
						when 'INDIVIDUALS'
							Utils.handle_individual(g, config, repo, staff, cwk_group)
						else
							show_help
					end
				when 'REMOVE'
					case opts.target
						when 'TEAMS'
							Utils.remove_team_members(g, config, repo, opts.extra_time)
						when 'INDIVIDUALS'
							Utils.remove_group_members(g, cwk_group, config)
						else
							show_help
					end
				else
					show_help
			end

		else
			show_help
		end
	end 
end

GLArgs.new.run 
