require 'open-uri'
require 'yaml'

def path
  File.expand_path("../..", __FILE__)
end

scraped_text = File.read('scrape.txt')
raw_pokedex = scraped_text.split('<a href="/us/pokedex/')[1..151]

pokedex = raw_pokedex.clone
pokedex.map! do |text|
  name = text.match(/<h5>(.*)<\/h5>/)[1]
  number = text.match(/pokedex\/detail\/(.*).png">/)[1]
  {
    name: name,
    # orig_url: text.match(/<img src="(.*)">/)[1],
    number: number,
    img: "#{number}-#{name}.png"
  }
end

# pokedex.each do |pokemon|
#   writepath = "#{path}/pokedex/#{pokemon[:img]}"
#   IO.copy_stream(URI.open(pokemon[:orig_url]), writepath)
# end

File.open(File.join(path, 'pokedex.yml'), 'w') do |file|
  file.write(Psych.dump(pokedex))
end