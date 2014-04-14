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
    # flash[:notice] = "testing flash"
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

      name = client.get('/me').username;

      erb :index, :locals => {:username => name}

   end

  get '/:client_id/:client_secret/:access_token' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];

    redirect '/'
  end

  # Delete a track.
  ##########################################################
  get '/delete:trackId' do

    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    })
    trackId = params[:trackId]
    client.delete('/me/tracks/' + trackId)
    flash[:notice] = "The photo has been deleted."
  end

end
