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
end

stocks = []

# Get stock code list
if config["stocks"] != nil
  stocks = config["stocks"].split(" ")
end

# Get information for each company
stocks.each do |stock|
  # Create class Stock and atts
  # Call api and retrieve values
  # Set values on Stock class
end
