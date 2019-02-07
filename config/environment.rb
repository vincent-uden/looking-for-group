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
