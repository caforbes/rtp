# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

require_relative 'database_storage'
require_relative 'session_storage'

configure do
  enable :sessions
  set :session_secret, 'secret' # in real production, revisit this
end

configure :development do
  also_reload 'database_storage.rb'
  also_reload 'session_storage.rb'
end

# def pokedex_path
#   if ENV["RACK_ENV"] == "test"
#     File.expand_path("../test", __FILE__)
#   elsif settings.development?
#     File.expand_path("../dev", __FILE__)
#   else
#     File.expand_path("..", __FILE__)
#   end
# end

def next_unrated_pokemon(available_pokemon, ratings)
  available_pokemon.reject { |pokemon| ratings[pokemon[:number]] }.first
end

# TODO: dynamically generate image link from id/name, don't store in db
helpers do
  def poke_image(img_link)
    "/pokedex/#{img_link}"
  end
end

before do
  @db = DatabaseStorage.new(logger)
  @ratings = SessionStorage.new(session, @db)
end

after do
  @db.disconnect
end

# Homepage
get '/' do
  erb :index
end

# Display form for rating the first unrated pokemon, based on ratings stored in session
get '/rate' do
  redirect '/results' if @ratings.full?

  @current_pokemon = @db.load_one_pokemon(@ratings.next_unrated_pokemon_id)

  erb :rate
end

# Submit a rating value for one pokemon and store in session
# If it's the last pokemon, submit all ratings to db
post '/rate/:pokemon_id' do
  @ratings.rate(params[:pokemon_id], params[:rating].to_i)

  if @ratings.full?
    @ratings.each do |id, values|
      @db.add_client_rating(id, values[:rating])
    end

    session[:submitted] = 'true'
    redirect '/results'
  else
    redirect '/rate'
  end
end

# Display interesting stored ratings from database
get '/results' do
  top_ids = @ratings.top_rated_pokemon_ids

  @client_top_pokemon = @db.load_all_pokemon
  @client_top_pokemon.select! do |pokemon|
    top_ids.include?(pokemon[:number])
  end

  @ratings_aggregate = @db.load_all_ratings

  erb :results
end
