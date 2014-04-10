require 'sinatra/base'
require "sinatra/config_file"
require 'soundcloud'
require 'hashie'
require 'httmultiparty'


class SoundcloudApp < Sinatra::Base
  register Sinatra::FormKeeper
  register Sinatra::ConfigFile
  register Sinatra::Flash

  configure do
    set :environment, :production
    enable :sessions
    set :session_secret, "Session Secret for shotgun development"
    set :protection, :except => :frame_options
    config_file "config/settings.yml"
  end

  # root route (really for testing only)
  get '/list' do
    # flash[:notice] = "testing flash"
    #haml :root
  end

  # initializer route
  get '/:client_id/:client_secret/:username/:password' do
    # flash[:notice] = "testing flash"

    session['client_id'] = params[:client_id];
    session['client_secret'] = params[:client_secret];
    session['username'] = params[:username];
    session['password'] = params[:password];


    # register a new client, which will exchange the username, password for an access_token
    # NOTE: the SoundCloud API Docs advise not to use the user credentials flow in a web app.
    # In any case, never store the password of a user.
    client = SoundCloud.new({
      :client_id     => '67925ad867fdc95e902b15afef1a6c81',
      :client_secret => '17927f3ba98bb0eec77ae19c61ded8f9',
      :username      => 'devops@gooddonegreat.com',
      :password      => 'opensaysm3'
    })
    # print logged in username
    puts client.get('/me').username
  end

  # View photos attached to application (main view)
  ############################################################
  get '/list' do
    "route created"
  end

end
