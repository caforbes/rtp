require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, 'secret' # in real production, revisit this
end

def pokedex_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test", __FILE__)
  elsif settings.development?
    File.expand_path("../dev", __FILE__)
  else
    File.expand_path("..", __FILE__)
  end
end

helpers do
  def each_pokemon
    pokedex = YAML.load_file(File.join(pokedex_path, 'pokedex.yml'))

    pokedex.each do |pokemon|
      yield pokemon[:name], pokemon[:number], poke_image(pokemon[:img])
    end
  end

  def poke_image(img_link)
    "/pokedex/#{img_link}"
  end
end

get '/' do
  erb :index
end

get '/rate' do
  erb :rate
end

post '/rate' do
  session[:rating] = {}
  each_pokemon do |name|
    if params[name]
      session[:rating][name] = params[name].to_i
    else
      status 422
      session[:message] = "You've gotta rate ALL the pokemon! No skipping!"
      break
    end
  end

  redirect '/results' unless session[:message]
  erb :rate
end

get '/results' do
  erb :results
end