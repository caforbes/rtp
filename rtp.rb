# frozen_string_literal: true

require 'sinatra'
require 'tilt/erubis'
require 'yaml'

require_relative 'database_storage'
require_relative 'session_storage'

configure do
  enable :sessions
  set :session_secret, 'secret' # FIXME: in real production, revisit this
end

configure :development do
  require 'sinatra/reloader'
  also_reload 'database_storage.rb'
  also_reload 'session_storage.rb'
  also_reload 'survey.rb'
end

# TODO: dynamically generate image link from id/name, don't store in db
helpers do
  def poke_image(img_link)
    "/pokedex/#{img_link}"
  end
end

before do
  @db = DatabaseStorage.new(logger)
  @client = SessionStorage.new(session) { @db.load_all_pokemon }
end

after do
  @db.disconnect
end

# Homepage
get '/' do
  erb :index
end

# Render form to rate the first unrated pokemon, based on saved session
get '/rate' do
  redirect '/results' if @client.survey.complete?

  @current_pokemon = @db.load_one_pokemon(@client.survey.next_unrated_id)

  erb :rate
end

# Submit a rating for one pokemon, store in session, submit survey if complete
post '/rate/:pokemon_id' do
  @client.survey[params[:pokemon_id]] = params[:rating].to_i

  redirect '/rate' unless @client.survey.complete?

  @db.submit_user_data(@client.survey.results)
  @client.mark_submitted
  session[:message] = 'Thanks, trainer! Your ratings have been submitted!'

  redirect '/results'
end

# Display interesting stored ratings from database
get '/results' do
  if @client.submitted?
    top_ids = @client.survey.top_rated_pokemon_ids
    @client_top_pokemon = top_ids.map { |id| @db.load_one_pokemon(id) }
  end

  # calculate aggregate best pokemon from db
  erb :results
end
