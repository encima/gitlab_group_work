require 'arg-parser'
require 'Gitlab'
require_relative 'utils'

class GLArgs 

	include ArgParser::DSL

	GUEST = 10
	MASTER = 40
	DESC = "A repository where you will be expected to submit all parts of your coursework"
	# initialize a new client
	# TODO add options for this to be set in config or args
	repo = "Class_Test"

	purpose <<-EOT
		test for arg parser
	EOT

	positional_arg :Action, 'Create or remove projects'
	#flag_arg :extra, 'flag'
	keyword_arg :target, 'Teams or individuals', short_key: '-t',	default: 'teams'
	keyword_arg :extra_time, 'Include or exclude extra time students', short_key: '-e', default: false
	keyword_arg :module, 'Module code', short_key: '-m', default: 'CM6122'
	keyword_arg :config, 'Path to config file', short_key: '-c', default: 'gitlab.yaml'
	keyword_arg :dry_run, 'Do not run with active connection to gitlab (not implemented)', default: false 
	def run

		if opts = parse_arguments
			config= YAML::load_file(opts.config)
			Gitlab.private_token = config["Gitlab"]["token"]
			Gitlab.endpoint =  config["Gitlab"]["endpoint"]
			g = Gitlab.client()
			module_code = opts.module 
			group = "#{module_code}_class_test"
			cwk_group = ""
			begin
				cwk_group = Gitlab.create_group(group, group)
			rescue
				cwk_group = Gitlab.group_search(group)[0]
			end
			puts cwk_group.id

			staff = []
			for member in config["staff"] do
				staff.push(Gitlab.user_search(member)[0])
			end
			case opts.action
				when 'CREATE'
					case opts.target 
						when 'teams'
							Utils.handle_groups(g, config, staff, cwk_group)
						when 'individuals'
							Utils.handle_individual(g, repo, config, staff, cwk_group)
						else
							show_help
					end
				when 'REMOVE'
					case opts.target
						when 'teams'
							Utils.remove_team_members(g, config, repo, opts.extra_time)
						when 'individuals'
							Utils.remove_group_members(g, cwk_group, config)
						else
							show_help
					end
				else
					show_help
			end

			puts opts 
		else
			show_help
		end
	end 
end

GLArgs.new.run 
