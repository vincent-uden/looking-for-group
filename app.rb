require_relative './config/environment'

class App < Sinatra::Base
  @@boss_image_path = '/img/boss/'

# --------------------------------- Sessions --------------------------------- #

  enable :sessions

  post '/login' do
    # user = User.login(params, self)
    # sinatra - flash
    user = Database.get_user_by_name(params['username'])
    hashed_password = BCrypt::Password.new(user.password)
    if hashed_password == params['password']
      session[:user_id] = user.id
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

  before do
    if session[:user_id]
      @current_user = User.get(session[:user_id])
    else
      @current_user = User.null_user
    end
  end

  get '/' do
    slim :index
  end

  get '/css/*.css' do |var|
    scss ('scss/' + var).to_sym
  end

  # Create new user page
  get '/account/new' do
    @current_user = User.new({'id' => true})
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
    Database.insert_user(username, BCrypt::Password.create(password), email, profile_img, rsn)
    redirect '/'
  end

  # Manage account page
  get '/account/manage' do
    @bosses = Database::get_bosses
    slim :'account/manage'
  end

  # Change boss interests
  post '/account/boss_settings' do
    p '### BOSS SETTINGS ###'
    p params
    p session[:user_id]
    Database.update_users_interests(session[:user_id], params)
    redirect '/account/manage'
  end

  # Boss information page
  get '/boss/:boss_id' do
    boss_data = Database.get_boss(params['boss_id'])
    @boss_name = boss_data.name
    @boss_image = @@boss_image_path + boss_data.boss_img
    slim :'boss/boss_page'
  end
end
