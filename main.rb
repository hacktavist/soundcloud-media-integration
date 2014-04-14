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
  get '/' do
    # flash[:notice] = "testing flash"


   end

  get '/:client_id/:client_secret/:access_token' do
    #create client object with access token
    'redirect page'
    client = SoundCloud.new({
      :client_id     => '67925ad867fdc95e902b15afef1a6c81',
      :client_secret => '17927f3ba98bb0eec77ae19c61ded8f9',
      :access_token => params[:access_token]
      })

    # updating the users profile description
    client.put("/me", :user => {:description => "Your description goes here."})
  end
end
