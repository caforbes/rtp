require 'pg'

class DatabaseStorage
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

  def add_client_rating(id, rating)
    sql = "INSERT INTO ratings (pokemon_id, rating) VALUES ($1, $2);"
    result = query(sql, id, rating)
    # probe the result object to return a boolean based on success?
  end

  def load_all_ratings
    # -- display all pokemon ids, names, img, alongside their no. of ratings of each value
    # -- id  | name     | imgname       | ratings_count | avg_rating | cum_rating | ...
    # -- 015 | Beedrill | 015-Bee...png |             2 |        1.5 |          4 | ...

    # SELECT * FROM pokemon AS p
    #   INNER JOIN ratings AS r ON p.id = r.pokemon_id
    #   GROUP BY p.id ;
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