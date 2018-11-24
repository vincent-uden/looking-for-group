class User
  def initialize(db_hash)
    @id = db_hash['id']
    @username = db_hash['username']
    @password = db_hash['password']
    @email = db_hash['email']
    @profile_img = db_hash['profile_img']
    @rsn = db_hash['rsn']
    @stats_id = db_hash['stats_id']
  end

  def self.get(id)
    db = SQLite3::Database.new('./database/user_data.db')
    db.results_as_hash = true
    result = db.execute('SELECT * FROM users WHERE id = ?', id)[0]
    User.new(result)
  end
end
