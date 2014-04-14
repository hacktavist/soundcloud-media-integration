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
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

      name = client.get('/me').username;

      erb :index, :locals => {:username => name}

   end

   get '/newUpload' do
     erb :newUpload
   end

   post '/:title/:upload' do
     client = SoundCloud.new({
       :client_id => session['cid'],
       :client_secret => session['cs'],
       :access_token => session['at']
       })
     track = client.post('/tracks', :track => {
       :title => params[:title],
       :asset_data => File.new(params[:upload])
       })
     erb :viewUpload
   end
  get '/:client_id/:client_secret/:access_token' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];

    redirect '/'
    # session['user_id'] = params[:user_id].to_s;
    # session['visitor_id'] = 'u' + params[:visitor_id].to_s;
    # session['app_id'] = 'a' + params[:app_id].to_s;
    # client = SoundCloud.new({
    #   :client_id     => '67925ad867fdc95e902b15afef1a6c81',
    #   :client_secret => '17927f3ba98bb0eec77ae19c61ded8f9',
    #   :access_token => params[:access_token]
    #   })
    #
    # track = client.post('/tracks', :track => {
    #    :title => "Crap Track",
    #    :asset_data => File.new('audio.mp3')
    #   })
    #   puts track.permalink_url
    #puts client.get('/me').username
    # updating the users profile description
    #client.put("/me", :user => {:description => "Your description goes here."})
  end
end
