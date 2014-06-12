require 'sinatra/base'
require "sinatra/config_file"
require 'soundcloud'
require 'hashie'
require 'httmultiparty'
require 'certified'
require 'json'


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
     erb :newUpload
   end

   get '/welcome' do
     client = SoundCloud.new({
       :client_id => session['cid'],
       :client_secret => session['cs'],
       :access_token => session['at']
       })
     name = client.get('/me').full_name;
     erb :welcome, :locals => {:username => name}
   end

   post '/upload' do
     client = SoundCloud.new({
       :client_id => session['cid'],
       :client_secret => session['cs'],
       :access_token => session['at']
       })
     tmpfile = "";
     tmpfile = params[:file][:tempfile];
     username = client.get('/me').username;
     fullName = client.get('/me').full_name;
     ##############################################################
     #need to programatically get the gdgUserID and applicationID #
     #this just shows the basic format of tagging                 #
     ##############################################################
     testingStringNum = "2222222";
     gdgUserID = "gdg:currentVisitorID="+testingStringNum;
     applicationID = "gdg:applicationID="+testingStringNum;
     tagListString = gdgUserID+" "+applicationID;

     #tmpfile = tmpfile.to_s
     track = client.post('/tracks', :track => {
       :title => params[:title],
       :description => params[:descr],
       :asset_data => File.new(tmpfile),
       :sharing => "private",
       :tag_list => tagListString
       })
       #puts track.tag_list


     redirect '/viewUpload'
   end

  get '/viewUpload' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

    tags = ["gdg:currentVisitorID=2222222"];
    trackListCall = client.get('/me/tracks');
    @trackList =  trackListCall.to_json
    #puts @trackList;
    @trackList = JSON.parse((trackListCall.to_json));
    puts @trackList;

    @totalTracks = @trackList.length
    erb :viewUpload 
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
  get '/tracks/edit/:id/:title/:description' do
    erb :editTrack, :locals => {:id => params[:id],
                                :title => params[:title],
                                :description => params[:description]}
  end
  get '/tracks/delete/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })

    client.delete('/tracks/' + params[:id]);
    redirect '/viewUpload'
  end
  post '/edit/track' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
      id = params[:id].to_s
      puts id
      track = client.get('/tracks/'+id)

      client.put(track.uri, :track => {
         :title => params[:title],
         :description => params[:descr]
        })
       redirect '/viewUpload'
  end
  get '/:client_id/:client_secret/:access_token' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];

    redirect '/welcome'
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

  get '/:client_id/:client_secret/:access_token' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];

    redirect '/'

  end


end
