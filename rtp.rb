require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

require_relative 'database_storage.rb'
require_relative 'session_storage.rb'

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

helpers do
  def poke_image(img_link)
    "/pokedex/#{img_link}"
  end
end

before do
  @db = DatabaseStorage.new(logger)
  @ratings = SessionStorage.new(session, @db)
end

# Homepage
get '/' do
  erb :index
end

# Display form for rating the first unrated pokemon, based on ratings stored in session
get '/rate' do
  redirect '/results' if @ratings.full?

  @pokedex = @db.load_all_pokemon()
  @current_pokemon = next_unrated_pokemon(@pokedex, @ratings)

  erb :rate
end

# Submit a rating value for one pokemon and store in session
post '/rate/:pokemon_id' do
  @ratings[params[:pokemon_id]] = params[:rating].to_i

  redirect '/rate' unless @ratings.full?

  # submit to db
  # session[:submitted] = "true"
  redirect '/results'
end

# Display interesting stored ratings from database / session
get '/results' do
  @pokedex = @db.load_all_pokemon()

  top_five_ids = @ratings.sample_top_five
  top_five = @pokedex.select { |pokemon| top_five_ids.include?(pokemon["id"]) }

  @ratings.clear_all
  erb :results
end