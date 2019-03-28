require_relative 'tables'

class Stat < Table
  table_name "stats"
  column :id, :int, :prim_key
  column :attack, :int
  column :defence, :int
  column :strength, :int
  column :hitpoints, :int
  column :ranged, :int
  column :prayer, :int
  column :magic, :int
  column :mining, :int
  column :herblore, :int
  column :thieving, :int
  column :farming, :int

  def initialize(db_hash)
    super()

    set_id        db_hash['id']
    set_attack    db_hash['attack']
    set_defence   db_hash['defence']
    set_strength  db_hash['strength']
    set_hitpoints db_hash['hitpoints']
    set_ranged    db_hash['ranged']
    set_prayer    db_hash['prayer']
    set_magic     db_hash['magic']
    set_mining    db_hash['mining']
    set_herblore  db_hash['herblore']
    set_thieving  db_hash['thieving']
    set_farming   db_hash['farming']
  end

  def self.create_stat(rsn)
    begin
      converted_name = RuneScapeApi::convert_username(rsn)
    rescue ArgumentError
      converted_name = ""
    end
    stats = RuneScapeApi::get_stats(converted_name)
    insert(stats.values)
    result = Database.execute('SELECT * FROM stats ORDER BY id DESC LIMIT 1')[0] # TODO: Refactor this to use select_all
    Stat.new result
  end

  def self.create_test_stat()
    stats = Stat.select_all order_by: 'id DESC', limit: 1
    no_id = stats[0].values
    no_id = no_id[1..no_id.length / 2 - 1]
    insert no_id
    result = Stat.select_all order_by: 'id DESC', limit: 1
    result = result[0]
    Stat.new result
  end
end

