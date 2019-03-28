require_relative 'tables'

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
    if validate_new_username columns[:username]
      # select :username, :email, join: Stat, limit: 10, debug: true
      stats = Stat.create_stat columns[:rsn]
      insert(columns.values + [stats.get_id, 0])
    end
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
      result = User.select :*, join: Stat, on: 'users.stat_id = stats.id', 
                               where: "users.id != #{get_id}", debug: true
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

