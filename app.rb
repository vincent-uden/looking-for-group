require_relative './config/environment'

class App < Sinatra::Base
  @@boss_image_path = '/img/boss/'

  def self.get(*args, &blk)
    super(args[0])
  end

  register Sinatra::Flash
# -------------------------------- Login --------------------------------- #

  enable :sessions

  post '/login' do # sinatra - flash
    User.login params['username'], params['password'], session
    redirect back
  end

  post '/logout' do
    session.destroy
    redirect '/'
  end

# ------------------------------ Login end ------------------------------- #

  before do
    if session[:user_id]
      @current_user = User.get(id: session[:user_id])
    else
      @current_user = User.null_user
    end
  end

  not_found do
    status 404
    slim :'404', layout: false
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
    User.create_user({
      username: params['username'], 
      password: BCrypt::Password.create(params['password']), 
      email:    params['email'], 
      rsn:      params['rsn']
    })
    redirect '/'
  end

  # Manage account page
  get '/account/manage' do
    @bosses = Database.get_bosses
    # To prevent several calls to database
    @interests = @current_user.get_interests
    slim :'account/manage'
  end

  # Show own profile
  get '/account/show', :login_required do
    @friends = @current_user.get_friends
    slim :'account/show'
  end

  # Change boss interests
  post '/account/boss_settings' do
    Database.update_users_interests(session[:user_id], params)
    redirect '/account/manage'
  end
  
  # Updating Dark Mode
  post '/account/manage/dark_mode/:enabled' do
    if params['enabled'] == 'true'
      @current_user.set_dark_mode 1
    elsif params['enabled'] == 'false'
      @current_user.set_dark_mode 0
    end
    @current_user.save
    redirect back
  end

  # Updating profile image
  post '/account/profile_img' do
    @current_user.save_profile_image params[:profile_img][:filename], params[:profile_img][:tempfile]
  end

  # Boss information page
  get '/boss/:boss_id' do
    boss_data = Database.get_boss params['boss_id']
    @boss_name = boss_data.get_name
    @boss_image = @@boss_image_path + boss_data.get_boss_img
    slim :'boss/boss_page'
  end

  # Explore new users
  get '/explore/find_teammates' do
    @pairs = @current_user.get_other_user_stat_pairs
    slim :'explore/find_teammates'
  end

  # Showing user profile
  get '/explore/profile/:user_id' do
    @profile_owner = User.get(id: params['user_id'].to_i, include_stats: true)
    @bosses = UserBossInterest.get_bosses @profile_owner.get_id
    slim :'explore/profile'
  end

  # Send friend request
  post '/explore/profile/add_friend/:user_id' do
    @other_user = User.get(id: params['user_id'])
    @current_user.add_friend @other_user
    redirect back
  end
end

