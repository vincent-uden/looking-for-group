require_relative './config/environment'

class App < Sinatra::Base
  @@boss_image_path = '/img/boss/'

# --------------------------------- Sessions --------------------------------- #

  enable :sessions

  post '/login' do
    # sinatra - flash
    User.login params['username'], params['password'], session
    redirect back
  end

  post '/logout' do
    session.destroy
    redirect '/'
  end

# ------------------------------- Sessions end ------------------------------- #

  before do
    if session[:user_id]
      @current_user = User.get(id: session[:user_id])
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
    @bosses = Database.get_bosses
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

  post '/account/dark_mode' do
    @current_user.set_dark_mode (@current_user.get_dark_mode == 1 ? 0 : 1)
    @current_user.save
    redirect back
  end

  # Boss information page
  get '/boss/:boss_id' do
    boss_data = Database.get_boss params['boss_id']
    @boss_name = boss_data.get_name
    @boss_image = @@boss_image_path + boss_data.get_boss_img
    slim :'boss/boss_page'
  end
end
