class App < Sinatra::Base
    get '/' do
        slim :index
    end

    get '/account/new' do
        slim :'account/new'
    end

    post '/account/new' do
        p params
        redirect '/'
    end
end