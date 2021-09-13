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

  def disconnect
    @db.close
  end

  def load_all_pokemon
    sql = "SELECT * FROM pokemon ORDER BY id ;"
    result = query(sql)
    result.map{ |row| parse_pokemon_to_hash(row) }
  end

  def load_one_pokemon(id)
    sql = "SELECT * FROM pokemon WHERE id=$1 ;"
    result = query(sql, id)

    parse_pokemon_to_hash(result.first)
  end

  def load_pokemon_from_list(id_list)
    sql = "SELECT * FROM pokemon WHERE id IN $1 ;"
    result = query(sql, id_list)

    result.map{ |row| parse_pokemon_to_hash(row) }
  end

  private

  def query(sql, *args)
    @logger.info "#{sql}: #{args}"
    @db.exec_params(sql, args)
  end

  def parse_pokemon_to_hash(row)
    { number: row["id"],
      name: row["name"],
      img: row["imgname"] }
  end
end