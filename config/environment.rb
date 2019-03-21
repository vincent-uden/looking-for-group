require_relative '../database/database'
require_relative '../database/models/tables'
require_relative '../highscore_api'

puts "--------------------"
puts "-    Restarting    -"
puts "--------------------"

if ENV['RACK_ENV'] == 'test'
  puts "- Test environment -"
  puts "--------------------"
  Database.db = SQLite3::Database.new ':memory:'
  Database.clear 'users'
  Database.clear 'bosses'
  Database.clear 'friend_relations'
  Database.clear 'stats'
  Database.clear 'user_boss_interests'
end

if ENV['offline'] == 'true'
  puts "- Using Offline Api-"
  puts "--------------------"
  RuneScapeApi.set_offline true
end

def dp(str)
  call = caller_locations(1, 1)[0]
  path = call.path().split "looking-for-group"
  path = path[1]
  print "#{path}:#{call.lineno()} "
  p str
end
