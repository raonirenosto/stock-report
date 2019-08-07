require 'yaml'

# Read config file
begin
  config =  YAML::load(File.read('config.yml'))
rescue
  puts "Could not open config.yml"
end

# Get Alpha Vantage API key
key = config["key"].to_s

# Key should be on config.yml
if key == nil ||
   key.strip.empty?
  puts "API key was not informed"
  exit
else
  puts "cool"
  puts key
end
