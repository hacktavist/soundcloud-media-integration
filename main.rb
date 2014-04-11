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


  # initializer route
  get '/:client_id/:client_secret/:access_token' do
    #create client object with access token
    client = SoundCloud.new(
      :client_id => params[:client_id], 
      :client_secret => params[:client_secret],
      :access_token => params[:access_token]) # Our awesome access token!

    # updating the users profile description
    client.put("/me", :user => {:description => "Your description goes here!"})

  end
end
