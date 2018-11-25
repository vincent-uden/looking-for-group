class Boss
  attr_reader :id, :name, :boss_img, :wiki_link
  def initialize(db_hash)
    @id = db_hash['id']
    @name = db_hash['name']
    @boss_img = db_hash['boss_img']
    @wiki_link = db_hash['wiki_link']
  end

  def self.get(id)
    db = SQLite3::Database.new('./database/user_data.db')
    db.results_as_hash = true
    result = db.execute('SELECT * FROM bosses WHERE id = ?', id)[0]
    Boss.new(result)
  end
end
