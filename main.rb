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

   end

   get '/newUpload' do
     erb :newUpload
   end

   post '/upload' do
     client = SoundCloud.new({
       :client_id => session['cid'],
       :client_secret => session['cs'],
       :access_token => session['at']
       })
    form do
      field :title, :present => true
      field :descr, :present => true
      field :file,   :present => true
    end

    if form.failed?
      flash[:warning] = "You have not filled out ."
      redirect '/newUpload';
    else


      tmpfile = params[:file][:tempfile]


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


     track = client.post('/tracks', :track => {
       :title => params[:title],
       :description => params[:descr],
       :asset_data => File.new(tmpfile),
       :sharing => "private",
       :tag_list => tagListString
       })
       puts track.tag_list


     redirect '/viewUpload'
   end
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
    puts @trackList;
    @trackList = JSON.parse((trackListCall.to_json));
    puts @trackList;



    @totalTracks = @trackList.length
    erb :viewUpload
  end

  get '/tracks/edit/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
      @id = params[:id];
      @track = client.get('/tracks/'+@id.to_s);

    erb :editTrack
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

      if params[:art] == nil
      client.put(track.uri, :track => {
         :title => params[:title],
         :description => params[:descr]
        })

      else
        temporary = params[:art][:tempfile]
        client.put(track.uri, :track => {
           :title => params[:title],
           :description => params[:descr],
           :artwork_data => File.new(temporary)
          })
      end

       redirect '/viewUpload'
  end
  get '/tracks/view/:id' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
    @id = params[:id]
    @track = client.get('/tracks/'+@id)
    @trackStream = @track['stream_url']
    @trackSToken = @track['secret_token']
    @title = @track['title']
    @description = @track['description']

    erb :viewUploadedSound
  end


  get '/:client_id/:client_secret/:access_token' do
    session['cid'] = params[:client_id];
    session['cs'] = params[:client_secret];
    session['at'] = params[:access_token];
    session['user_tag'] = "gdg:currentVisitorID=2222222";
    session['user_app_tag'] = session['user_tag'].to_s+" gdg:applicationID=1111111";

    puts session['user_app_tag']

    redirect '/viewUpload'

  end

  get '/attach/:soundId' do
    client = SoundCloud.new({
      :client_id => session['cid'],
      :client_secret => session['cs'],
      :access_token => session['at']
      })
    soundIds = params[:soundId].to_s
      if soundIds.length > 0
        attach = soundIds.split(",")
        puts attach
        attach.each do |id|
          track = client.get('/tracks/'+id)
          client.put(track.uri, :track => {
             :tag_list => session['user_app_tag'].to_s
            })
        end #end loop
      end #end if

      redirect 'viewUpload'

  end #end attach route

end
