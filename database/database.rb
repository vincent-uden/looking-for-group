class Database
  def self.print
    p "###kek###"
  end

  def self.clear(db)
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('CREATE TABLE users
      (id INTEGER PRIMARY KEY AUTOINCREMENT, username VARCHAR(40) NOT NULL,
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
    stat_id = self.insert_stats(db, rsn)[0]
    db.execute('INSERT INTO users (username, password, email, profile_img, rsn, stat_id) VALUES (?, ?, ?, ?, ?, ?)', 
      [username, hashed_pwd, email, profile_img, rsn, stat_id])
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
    db.execute('SELECT * FROM stats ORDER BY id DESC LIMIT 1')[0]
  end

  def self.insert_boss(db, name, boss_img, wiki_link)
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link)
                VALUES (?, ?, ?)', [name, boss_img, wiki_link])
  end

  def self.insert_user_boss_interest(db, username, boss_name)
    user_id = db.execute('SELECT id FROM users 
                          WHERE username = ?', username)
    boss_id = db.execute('SELECT id FROM bosses
                          WHERE name = ?', boss_name)
    db.execute('INSERT INTO user_boss_interests (user_id, boss_id)
                VALUES (?, ?)', [user_id, boss_id])
  end

  def self.insert_bosses(db)
    # Bosses
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Callisto', 'Callisto.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Chaos Elemental', 'Chaos Elemental.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Chaos Fanatic', 'Chaos Fanatic.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Commander Zilyana', 'Commander Zilyana.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) VALUES (?, ?, ?)', ['Crazy Archaeologist', 'Crazy archaeologist.png', 'oldschool.runesacpe.wiki']) 
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Dagannoth Kings', 'Dagannoth Rex.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['General Graardor', 'General Graardor.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Giant Mole', 'Giant_Mole.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Kalphite Queen', 'Kalphite Queen.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['King Black Dragon', 'King Black Dragon.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Kree\'arra', 'Kreearra.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['K\'ril Tsutsaroth', 'Kril Tsutsaroth.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Scorpia', 'Scorpia.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Venenatis', 'Venenatis.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Raids 2', 'Verzik.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Vet\'ion', 'Vetion.png', 'oldschool.runesacpe.wiki'])
    db.execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Raids 1', 'Xeric.png', 'oldschool.runesacpe.wiki'])
  end

end
