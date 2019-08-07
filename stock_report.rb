# Read file with Alpha Vantage API key
begin
  key_file = File.read("key.dat")
rescue
  pp "Could not open key.dat"
end

# Key should be on key.dat second line
key = key_file.lines[1]

if key == nil ||
   key.start_with?("#") ||
   key.strip.empty?
  pp "API key was not informed"
  exit
end
