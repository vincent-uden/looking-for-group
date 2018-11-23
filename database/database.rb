class Database
  def self.print
    p "###kek###"
  end

  def self.clear(db)
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('CREATE TABLE users
      (id INTEGER PRIMARY KEY AUTOINCREMENT,
       username VARCHAR(40) NOT NULL,
       password VARCHAR(40) NOT NULL,
       email VARCHAR(100) NOT NULL,
       profile_img VARCHAR(40),
       rsn VARCHAR(40),
       stat_id INTEGER,
       FOREIGN KEY(stat_id) REFERENCES stats(id))')
    
    db.execute('DROP TABLE IF EXISTS stats')
    db.execute('CREATE TABLE stats
      (id INTEGER PRIMARY KEY AUTOINCREMENT,
       attack INTEGER,
       defence INTEGER,
       strength INTEGER,
       hitpoints INTEGER,
       ranged INTEGER,
       prayer INTEGER,
       magic INTEGER,
       mining INTEGER,
       herblore INTEGER,
       thieving INTEGER,
       farming INTEGER)')

    db.execute('DROP TABLE IF EXISTS bosses')
    db.execute('CREATE TABLE bosses
      (id INTEGER PRIMARY KEY AUTOINCREMENT,
       name VARCHAR(60) NOT NULL,
       boss_img VARCHAR(40),
       wiki_link VARCHAR(255))')

    db.execute('DROP TABLE IF EXISTS user_boss_interests')
    db.execute('CREATE TABLE user_boss_interests
      (user_id INTEGER NOT NULL,
       boss_id INTEGER NOT NULL)')
  end

  def self.insert_user(db, username, hashed_pwd, email, profile_img, rsn)
    p "TEST1"
    stat_id = self.insert_stats(db, rsn)[0]
    p "TEST2"
    db.execute('INSERT INTO users (username, password, email, profile_img, rsn, stat_id) VALUES (?, ?, ?, ?, ?, ?)', 
      [username, hashed_pwd, email, profile_img, rsn, stat_id])
    p "TEST3"
  end

  # Returns the inserted row
  def self.insert_stats(db, rsn)
    begin
      converted_name = RuneScapeApi::convert_username(rsn)
    rescue ArgumentError
      converted_name = ""
    end
    stats = RuneScapeApi::get_stats(converted_name)
    db.execute('INSERT INTO stats (attack, defence, strength, hitpoints, ranged, prayer, magic, mining, herblore, thieving, farming) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
                stats.values)
    db.execute('SELECT * FROM stats ORDER BY id LIMIT 1')[0]
  end
end