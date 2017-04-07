require 'arg-parser'

class Args 

	include ArgParser::DSL

	purpose <<-EOT
		test for arg parser
	EOT

	positional_arg :pos_arg, 'pos arg'


	def run
		if opts = parse_arguments
			puts opts 
		else
			show_help
		end
	end 
end

Args.new.run 
