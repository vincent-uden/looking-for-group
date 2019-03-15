class Column
  attr_reader :name, :data_type, :no_null, :unique, :prim_key, :belongs_to
  def initialize(name, data_type, options={})
    @name = name
    @data_type = data_type
    @no_null = options[:no_null]
    @unique = options[:unique]
    @prim_key = options[:prim_key]
    @belongs_to = options[:belongs_to] 
    @value = nil
  end

  def set_val(value)
    @value = value
  end 
  def get_val
    @value
  end
  
  def to_s
    output = "-Column-\n"
    instance_variables.map do |var|
      output += "  " + var.to_s[1..var.length - 1] + ": " + (instance_variable_get var).to_s + "\n"
    end
    return output
  end
end

class Table
  
  def initialize
    @column_values = []
  end

  def self.table_name(name)
    @table_name = name
  end

  def self.get_table_name
    @table_name
  end

  def self.column(*args)
    if @columns == nil
      @columns = []
    end
    if args.include? :prim_key # Autoincrementing primary key
      @columns << (Column.new args[0], :int, prim_key: true)
    else # Arg[1] will be datatype
      options = {}
      options[:no_null] = args.include? :no_null
      options[:unique]  = args.include? :unique
      if args.include? :foreign_key
        i = -1
        # Find foreign key flag index
        # To find index of other tables name
        args.each_with_index do |arg, index|
          if arg == :foreign_key
            i = index
            break
          end
        end
        options[:belongs_to] = args[i + 1]
      end
      @columns << (Column.new args[0], options)
    end
  end

  def self.get_columns
    @columns
  end

  def self.belongs_to(table_name, name)
    column (name.to_s + '_id').to_sym, :foreign_key, table_name
  end

  def method_missing(method_name, *args, &blk)
    if method_name.to_s[0..3] == "get_" # Get value in column
      col_name = method_name.to_s[4..-1]
      self.class.get_columns.each_with_index do |col, index|
        if col.name == col_name.to_sym
          return @column_values[index]
        end
      end
      raise "Column #{col_name} does not exist"
    # Set value in column
    elsif method_name.to_s[0..3] == "set_"
      col_name = method_name.to_s[4..-1]
      self.class.get_columns.each_with_index do |col, index|
        if col.name == col_name.to_sym
          @column_values[index] = args[0]
          return
        end
      end
      raise "Column #{col_name} does not exist"
    end
    super(method_name, *args, &blk)
  end

  def self.insert(values)
    query = "INSERT INTO #{get_table_name} ("
    get_columns.each do |col|
      if !col.prim_key
        query += col.name.to_s + ", "
      end
    end
    query = query[0..-3]
    query += ") VALUES ("
    get_columns.each do |col|
      if !col.prim_key
        query += "?, "
      end
    end
    query = query[0..-3]
    query += ")"
    Database.execute query, values
  end

  def self.select_all(options)
    query = "SELECT * FROM #{get_table_name} "
    if options[:join]
      query += "JOIN #{options[:join].get_table_name} "
      if options[:on]
        query += "ON #{options[:on]} "
      end
    end
    if options[:where]
      query += "WHERE #{options[:where]} "
    end
    if options[:order_by]
      query += "ORDER BY #{options[:order_by]} "
    end
    if options[:limit]
      query += "LIMIT #{options[:limit]} "
    end
    query += ";"
    if options[:debug]
      p query
    end
    Database.execute query, options[:values]
  end

  def save(*args)
    if args.length == 0
      id_col = self.class.get_columns.select do |col|
        col.name == :id
      end
      id_col = id_col[0].name.to_s
    else
      id_col = args[0]
    end

    query = "UPDATE #{self.class.get_table_name} SET "
    query = self.class.get_columns.inject(query) do |acc, col|
      acc + col.name.to_s + " = ?, "
    end
    query = query[0..-3] # remove last =?,
    
    query += " WHERE #{id_col.to_s} = ?"
    Database.execute(query, @column_values + [@column_values.first])
  end

  def to_s
    output = "TABLE: #{self.class.get_table_name}\n"
    get_columns.each do |col|
      output += col.to_s
    end
    return output
  end

end

class NullUser
  def initialize()
  end

  def get_username
    ""
  end
  
  def get_interests
    []
  end

  def null?
    true
  end

  def method_missing(method_name, *args, &blk)
    if User.method_defined? method_name
      return
    elsif method_name.to_s[0..3] == "get_"
      return
    end
    super(method_name, *args, &blk)
  end
end

class User < Table
  table_name 'users'
  column :id, :int, :prim_key
  column :username, :string40, :no_null, :unique
  column :password, :string40, :no_null
  column :email, :string100, :no_null
  column :rsn, :string40
  belongs_to :stats, 'stat' #has_many :users 
  column :dark_mode, :int

  def initialize(db_hash)
    super()
    
    set_id db_hash['id']
    set_username db_hash['username']
    set_password db_hash['password']
    set_email db_hash['email']
    set_rsn db_hash['rsn']
    set_stat_id db_hash['stat_id']
    set_dark_mode db_hash['dark_mode']
    @db_hash = db_hash
    # ------------------- #
  end

  def password_match?(password)
    BCrypt::Password.new(@password) == hashed_password
  end

  def null?
    get_id == nil
  end

  def self.login(browser_username, browser_pass, session)
    user = get name: browser_username
    login_success = BCrypt::Password.new(user.get_password) == browser_pass && (!user.null?)
    if login_success
      session[:user_id] = user.get_id
    end
  end

  def self.get(identifier)
    options = identifier
    if options[:include_stats]
      if options[:id]
        result = select_all join: Stat, on: 'users.stat_id = stats.id', where: "users.id = #{identifier[:id]}"
      elsif options[:name]
        result = select_all join: Stat, on: 'users.stat_id = stats.id', where: "username = #{identifier[:name]}"
      end
    else
      if identifier[:id]
        result = Database.execute("SELECT * FROM #{get_table_name} WHERE id = ?", identifier[:id])
      elsif identifier[:name]
        result = Database.execute("SELECT * FROM #{get_table_name} WHERE username = ?", identifier[:name])
      end
    end
    if result.empty?
      user = null_user
    else
      user = User.new(result[0])
      user.set_stat_model (Stat.new result[0])
    end
    user
  end

  def self.null_user()
    NullUser.new
  end

  def self.validate_new_username(username)
    is_ok = true
    is_ok = is_ok && username.length > 3
    is_ok = is_ok && username == username[/[a-zA-Z0-9\-\_\.]+/]
  end

  def self.create_user(columns)
    # Requirements for username:
    #   At least 4 characters long
    #   Alphanumeric (0-9, A-z, _-.)
    stats = Stat.create_stat columns[:rsn]
    insert(columns.values + [stats.get_id, 0])
  end

  def self.create_test_user(columns)
    stats = Stat.create_test_stat
    insert(columns.values + [stats.get_id, 0])
  end

  def get_interests
    UserBossInterest.get_users_interests get_id
  end

  def save_profile_image(filename, tmp_file)
    ext = File.extname(filename)
    new_file_name = get_id.to_s + ext
    image_dir = "./public/img/profile_imgs/"
    File.open(image_dir + new_file_name, "wb") do |f|
      f.write(tmp_file.read)
    end
  end

  def get_profile_img
    image_dir = "./public/img/profile_imgs/"
    external_image_dir = "/img/profile_imgs/"
    all_imgs = Dir.entries(image_dir)
    image_name = ""
    all_imgs.each do |img|
      if File.basename(img, ".*") == get_id.to_s
        image_name = external_image_dir + img
      end
    end
    return image_name
  end

  def set_stat_model(stats)
    @stat_model = stats
  end

  def get_stat_model
    @stat_model
  end

  def get_other_user_stat_pairs
    if get_id
      result = User.select_all join: Stat, on: 'users.stat_id = stats.id', 
                               where: "users.id != #{get_id}"
      models = result.map do |row|
        User.new row
      end
      stats = result.map do |row|
        Stat.new row
      end
      models.zip stats
    else
      return []
    end
  end

  def get_db_hash
    @db_hash
  end

  def is_friend?(other_user)
    friendship = FriendRelation.select_all where: "((user1 = #{get_id}) AND (user2 = #{other_user.get_id}))"
    return friendship.length > 0
  end

  def add_friend(other_user)
    relation = FriendRelation.null_friendship
    relation.set_user1 get_id
    relation.set_user2 other_user.get_id

    if !is_friend?(other_user)
      relation.save_as_new_relation
      relation.flip.save_as_new_relation
    end
  end

  def get_friends()
    friends = FriendRelation.select_all where: "user1 = #{get_id}"
    friends.map! do |hash|
      User.get id: hash['user2']
    end
  end

end

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

class UserBossInterest < Table
  table_name 'user_boss_interests'
  column :user_id, :int, :no_null
  column :boss_id, :int, :no_null

  def initialize(db_hash)
    super()

    set_user_id db_hash['user_id']
    set_boss_id db_hash['boss_id']
  end

  def self.get_bosses(user_id)
    # TODO: User id for user 15 is nil
    result = select_all join: Boss, on: 'boss_id = bosses.id', 
                        where: "user_id = #{user_id}"
    bosses = result.map do |row|
      Boss.new row
    end
  end

  def self.get_users_interests(user_id)
    result = select_all where: "user_id = ?", values: [user_id]
  end
end

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


class FriendRelation < Table
  table_name "friend_relations"
  column :user1, :int, :no_null
  column :user2, :int, :no_null

  def initialize(db_hash)
    super()

    set_user1 db_hash['user1']
    set_user2 db_hash['user2']
  end

  def self.null_friendship
    FriendRelation.new({})
  end
  
  def save_as_new_relation
    self.class.insert [get_user1, get_user2]
  end
  
  def flip
    tmp = self.class.null_friendship
    tmp.set_user1 get_user2
    tmp.set_user2 get_user1
    return tmp
  end

  def flip!
    tmp = get_user1
    set_user1 get_user2
    set_user2 tmp
  end
end

