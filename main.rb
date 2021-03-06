require 'sinatra/base'
require "sinatra/config_file"
require "rack-flash"
require 'soundcloud'
require 'hashie'
require 'httmultiparty'
require 'certified'
require 'json'
require "sinatra/formkeeper"


class SoundcloudApp < Sinatra::Base
  register Sinatra::FormKeeper
  register Sinatra::ConfigFile
  # register Sinatra::Flash
  use Rack::Flash

  configure do
    set :environment, :production
    enable :sessions
    set :session_secret, "Session Secret for shotgun development"
    set :protection, :except => :frame_options
    config_file "config/settings.yml"
    #set :person
  end


  # initializer route

  get '/' do
    # flash[:notice] = "testing flash"
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })


    #settings.person = client
      name = client.get('/me').username;

      erb :index, :locals => {:username => name}

   end

   get '/newUpload' do
     haml :newUpload
   end

   post '/upload' do
    # create soundcloud client
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    })

    # validation rules
    form do
      field :file, :present => true
    end

    #test form
    if form.failed?
      flash[:notice] = "You must choose an audio file."
      redirect '/newUpload';

    # form was successful
    else
      tmpfile = "";
      tmpfile = params[:file][:tempfile]
      name = params[:file][:filename]

      # custom file extension validation
      if !/mp3$/.match(name)
        flash[:notice] = "Invalid File Type."
        redirect '/newUpload';
      else
        tagListString = "#{session[:visitor_id]} #{session[:req_id]}"
        track = client.post('/tracks', :track => {
          :title => params[:title],
          :description => params[:descr],
          :asset_data => File.new(tmpfile),
          :sharing => "private",
          :tag_list => tagListString
        })
      end
    end #form.failed?

    redirect '/index'
  end

  get '/index' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    })

    trackListCall = client.get('/me/tracks')

    @trackList = JSON.parse((trackListCall.to_json));

    @trackList = @trackList.reject { |t| t['tag_list'] != "#{session[:visitor_id]} #{session[:req_id]}" }

    puts @trackList
    @totalTracks = @trackList.length
    haml :index
  end

  get '/play/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

      track = client.get('/tracks/'+params[:id]);
      stream_url = client.get(track.stream_url, :allow_redirects => true);

      puts stream_url.location
  end
  get '/tracks/edit/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    })

    @track = client.get("/tracks/#{params[:id]}");
    erb :editTrack, :locals => {:id => params[:id],
                                :title => @track['title'],
                                :description => @track['description']}

  end
  get '/tracks/delete/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

    client.delete('/tracks/' + params[:id]);
    redirect '/index'
  end
  post '/edit/track' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
      id = params[:id].to_s
      #puts id
      track = client.get('/tracks/'+id)

      client.put(track.uri, :track => {
         :title => params[:title],
         :description => params[:descr]
        })
       redirect '/index'
  end
  get '/tracks/view/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
    @trackStream = ""
    @trackSToken = ""
    trackListCall = client.get("/tracks/#{params[:id]}");
    track =  JSON.parse(trackListCall.to_json);
    @trackSToken = track['secret_token']
    @trackStream = track['stream_url']
    erb :indexedSound,
      :locals => {
        :id => params[:id],
        :title => track['title'],
        :description => track['description'],
        :soundArt => track['soundArt']
      }
  end


  get '/init/:client_id/:client_secret/:access_token/:visitor_id/:req_id/:mode' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];
    session['visitor_id'] = "u" + params[:visitor_id];
    session['req_id'] = "a" + params[:req_id];
    session['mode'] = params[:mode];

    redirect '/index'

  end

  get '/tracks/attach/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    });

    track = client.get("/tracks/#{params[:id]}")
    tags = track.tag_list;

    client.put(track.uri, :track => {
     :tag_list => "#{tags} #{session[:req_id]}"
    });
    "done"
  end

  get '/tracks/detach/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
    });

    track = client.get("/tracks/#{params[:id]}")

    tags = (track.tag_list.split(" ") - [session[:req_id]]).join(" ");

    client.put(track.uri, :track => {
     :tag_list => "#{tags}"
    });
    "done"
  end
end
