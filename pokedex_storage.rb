require 'pg'

class PokedexReader
  include Enumerable

  def initialize
    @db = PG.connect(dbname: 'rtp')
    @dex = fetch_all_pokemon
  end

  def size
    @dex.size
  end

  def each
    @dex.each do |pokemon|
      yield pokemon[:name], pokemon[:number], pokemon[:img]
    end
  end

  private

  def fetch_all_pokemon
    sql = "SELECT * FROM pokemon ORDER BY id ;"
    result = @db.exec(sql)
    result.map{ |tuple| parse_pokemon_to_hash(tuple) }
  end

  def parse_pokemon_to_hash(tuple)
    { number: tuple["id"],
      name: tuple["name"],
      img: tuple["imgname"] }
  end
end