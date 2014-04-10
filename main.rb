require 'sinatra/base'
require "sinatra/config_file"
require 'soundcloud'
require 'hashie'
require 'httmultiparty'
require 'certified'


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

  get '/' do
    "route created"
  end


  # initializer route
  get 'https://soundcloudapp.dev/' do
    # flash[:notice] = "testing flash"

    #session['client_id'] = params[:client_id];
    #session['client_secret'] = params[:client_secret];

    client = SoundCloud.new({
      :client_id     => '67925ad867fdc95e902b15afef1a6c81',
      :client_secret => '17927f3ba98bb0eec77ae19c61ded8f9',
      :username      => 'devops@gooddonegreat.com',
      :password      => 'opensaysm3'
    })

    # print logged in username
    puts ("#{client.get('/me').username}")

    #redirect '/list/1'
  end
end