require_relative 'tables'

class Boss < Table
  table_name 'bosses'
  column :id, :int, :prim_key
  column :name, :string60, :no_null
  column :boss_img, :string40
  column :wiki_link, :string255
  def initialize(db_hash)
    super()

    set_id db_hash['id']
    set_name db_hash['name']
    set_boss_img db_hash['boss_img']
    set_wiki_link db_hash['wiki_link']
  end

  def self.get(identifier)
    if identifier[:id]
      result = Database.execute("SELECT * FROM #{get_table_name} WHERE id = ?", identifier[:id])[0]
    elsif identifier[:name]
      result = Database.execute("SELECT * FROM #{get_table_name} WHERE name = ?", identifier[:name])[0]
    end
    Boss.new(result)
  end
end

