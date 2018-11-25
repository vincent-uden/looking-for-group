require_relative '../database/database'
require_relative '../database/models/user'
require_relative '../database/models/boss'
require_relative '../highscore_api'

require 'sqlite3'
require 'bcrypt'

p "------------------"
p "-   Restarting   -"
p "------------------"
db = SQLite3::Database.new './database/user_data.db'
#Database::clear db
#Database::insert_bosses(db)


p db.execute('SELECT * FROM bosses')

#p Database::insert_stats(db, "Xor Vralin 2")
#Database::insert_user(db, "Xor_Vralin_2", "kek", "kek@gmail.com",
                     #"gnome.jpg", "Xor Vralin 2")

