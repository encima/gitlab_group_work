
config = YAML::load_file('gitlab.yaml')

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end
csv = CSV.new(config["students"], :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
students = csv.to_a.map {|row| row.to_hash }

for row in students do
    puts row
end