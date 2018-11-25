require_relative './config/environment'

class App < Sinatra::Base
  @@boss_image_path = '/img/boss/'
# --------------------------------- Sessions --------------------------------- #
  enable :sessions

  post '/login' do
    db = SQLite3::Database.new('./database/user_data.db')
    db.results_as_hash = true
    user = db.execute('SELECT id, password FROM users 
                       WHERE username = ?', params['username'])[0]
    hashed_password = BCrypt::Password.new(user['password'])
    if hashed_password == params['password']
      session[:user_id] = user['id']
      p "Success"
    else
      p "Fail"
    end
    redirect back
  end

  post '/logout' do
    session.destroy
    redirect '/'
  end
# ------------------------------- Sessions end ------------------------------- #
  get '/' do
    if session[:user_id]
      @current_user = User.get(session[:user_id])
    end
    slim :index
  end
  # Create new user page
  get '/account/new' do
    @current_user = true
    slim :'account/new'
  end
  # Create account confirmation
  post '/account/new' do
    p params
    username = params['username']
    # Encrypt
    password = params['password']
    email = params['email']
    profile_img = nil
    rsn = params['rsn']
    db = SQLite3::Database.new('./database/user_data.db')
    Database::insert_user(db, username, BCrypt::Password.create(password), email, profile_img, rsn)
    redirect '/'
  end
  # Manage account page
  get '/account/manage' do
    if session[:user_id]
      @current_user = User.get(session[:user_id])
    end
    db = SQLite3::Database.new('./database/user_data.db')
    db.results_as_hash = true
    results = db.execute('SELECT * FROM bosses')
    @bosses = []
    results.each do |row|
      @bosses << Boss.new(row)
    end
    slim :'account/manage'
  end
  # Boss information page
  get '/boss/:boss_id' do
    if session[:user_id]
      @current_user = User.get(session[:user_id])
    end
    db = SQLite3::Database.new('./database/user_data.db')
    db.results_as_hash = true
    boss_data = db.execute('SELECT * FROM bosses
                            WHERE id = ?', params['boss_id'])[0]
    @boss_name = boss_data['name']
    @boss_image = @@boss_image_path + boss_data['boss_img']
    slim :'boss/boss_page'
  end
end
