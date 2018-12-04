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
    if args[1] == :prim_key # Autoincrementing primary key
      @columns << (Column.new args[0], prim_key: true)
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
    p method_name
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
  end


  # MAKE STATIC METHOD  # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
  # Convert columns to class variables but not the values in the columns
  def insert(values)
    query = "INSERT INTO #{get_table_name} ("
    # Fråga Daniel om each vs map
    self.class.get_columns.each do |col|
      output += col.name.to_s + ", "
    end
    output = output[0..-2]
    output += ")"
    p output
  end
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

  def to_s
    output = "TABLE: #{self.class.get_table_name}\n"
    get_columns.each do |col|
      output += col.to_s
    end
    return output
  end
end

class User < Table
  table_name 'users'
  column :id, :prim_key
  column :username, :string40, :no_null, :unique
  column :password, :string40, :no_null
  column :email, :string100, :no_null
  column :profile_img, :string40
  column :rsn, :string40
  belongs_to :stats, 'stats' #has_many :users 
  column :dark_mode, :int
  def initialize(db_hash)
    super()

    set_id db_hash['id']
    set_username db_hash['username']
    set_password db_hash['password']
    set_email db_hash['email']
    set_profile_img db_hash['profile_img']
    set_rsn db_hash['rsn']
    set_stats_id db_hash['stats_id']
    set_dark_mode db_hash['dark_mode']
    # ------------------- #
  end

  def password_match?(password)
    BCrypt::Password.new(@password) == hashed_password
  end

  def self.login(browser_username, browser_pass, session)
    user = get name: browser_username
    if BCrypt::Password.new(user.get_password) == browser_pass
      session[:user_id] = user.get_id
    end
  end

  def self.get(identifier)
    if identifier[:id]
      result = Database.execute("SELECT * FROM #{get_table_name} WHERE id = ?", identifier[:id])[0]
    elsif identifier[:name]
      result = Database.execute("SELECT * FROM #{get_table_name} WHERE username = ?", identifier[:name])[0]
    end
    User.new(result)
  end

  def self.null_user()
    User.new({'id'          => nil,
              'username'    => '',
              'password'    => nil,
              'email'       => nil,
              'profile_img' => nil,
              'rsn'         => nil,
              'stats_id'    => nil,
              'dark_mode'   => 0
              })
  end
end

class Boss < Table
  table_name 'bosses'
  column :id, :prim_key
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
