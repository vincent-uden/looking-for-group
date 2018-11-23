require_relative '../database/database'
require_relative '../highscore_api'

require 'sqlite3'

p "------------------"
p "-   Restarting   -"
p "------------------"
db = SQLite3::Database.new './database/user_data.db'
Database::clear db
db.execute('INSERT INTO bosses (name, boss_img, wiki_link) VALUES (?, ?, ?)', ['Kek', 'kek.png', 'kek.com'])

p db.execute('SELECT * FROM bosses')

#p Database::insert_stats(db, "Xor Vralin 2")
Database::insert_user(db, "Xor_Vralin_2", "kek", "kek@gmail.com",
                     "gnome.jpg", "Xor Vralin 2")
