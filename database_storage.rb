require 'pg'

class DatabaseStorage
  include Enumerable

  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'rtp')
          end
    @logger = logger
  end

  def load_all_pokemon
    sql = "SELECT * FROM pokemon ORDER BY id ;"
    result = query(sql)
    result.map{ |tuple| parse_pokemon_to_hash(tuple) }
  end

  def load_one_pokemon(id)
    sql = "SELECT * FROM pokemon WHERE id=$1 ;"
    result = query(sql, id)

    parse_pokemon_to_hash(result.first)
  end

  def load_pokemon_from_list(id_list)
    sql = "SELECT * FROM pokemon WHERE id IN $1 ;"
    result = query(sql, id)

    result.map{ |tuple| parse_pokemon_to_hash(tuple) }
  end

  private

  def query(sql, *args)
    @logger.info "#{sql}: #{args}"
    @db.exec_params(sql, args)
  end

  def parse_pokemon_to_hash(tuple)
    { number: tuple["id"],
      name: tuple["name"],
      img: tuple["imgname"] }
  end
end