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
    @columns = []
  end

  def self.table_name(name)
    @table_name = name
  end

  def self.get_table_name
    @table_name
  end

  def column(*args)
    if args[1] == :prim_key # Autoincrementing primary key
      @columns << (Column.new args[0], prim_key: true)
    else # Arg[1] will be datatype
      options = {}
      options[:no_null] = true if args.include? :no_null
      options[:unique]  = true if args.include? :unique
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

  def method_missing(method_name, *args, &blk)
    # Get value in column
    if method_name.to_s[0..3] == "get_"
      col_name = method_name.to_s[4..-1]
      @columns.each do |col|
        if col.name == col_name.to_sym
          return col.get_val
        end
      end
      raise "Column #{col_name} does not exist"
    # Set value in column
    elsif method_name.to_s[0..3] == "set_"
      col_name = method_name.to_s[4..-1]
      @columns.each do |col|
        if col.name == col_name.to_sym
          col.set_val args[0]
          return
        end
      end
      raise "Column #{col_name} does not exist"
    end
  end

  def belongs_to(table_name, name)
    column (name.to_s + '_id').to_sym, :foreign_key, table_name
  end

  def to_s
    output = "TABLE: #{self.class.get_table_name}\n"
    @columns.each do |col|
      output += col.to_s
    end
    return output
  end
end

class User < Table
  #attr_reader :id, :username, :password, :email, :profile_img, :rsn, :stats_id, :dark_mode
  
  #columns 'stats_id'
  
  table_name 'users'
  def initialize(db_hash)
    super()
    # Fråga Daniel om kolumner som class/instance variabler
    column :id, :prim_key
    column :username, :string40, :no_null, :unique
    column :password, :string40, :no_null
    column :email, :string100, :no_null
    column :profile_img, :string40
    column :rsn, :string40
    belongs_to :stats, 'stats' #has_many :users 
    column :dark_mode, :int
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
