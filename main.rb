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

    #session['client_id'] = params[:client_id];
    #session['client_secret'] = params[:client_secret];

    client = SoundCloud.new({
      :client_id     => '67925ad867fdc95e902b15afef1a6c81',
      :client_secret => '17927f3ba98bb0eec77ae19c61ded8f9',
      :redirect_uri => 'https://www.google.com/'
    })
redirect client.authorize_url()
code = params[:code]
access_token = client.exchange_token(:code => code)


# make an authenticated call
current_user = client.get('/me')
puts current_user.username
    # print logged in username
    #puts ("#{client.get('/me').username}")
    redirect '/:access_token'
  end

  get '/:access_token' do
    #create client object with access token
    'stuff'
   client = Soundcloud.new(:access_token => 'YOUR_ACCESS_TOKEN')
  end
end
