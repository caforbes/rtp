# frozen_string_literal: true

require 'pg'

# for handling connection to db and submission of ratings
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
    sql = 'SELECT * FROM pokemon ORDER BY id ;'
    result = query(sql)
    result.map { |row| pokemon_to_h(row) }
  end

  def load_one_pokemon(id)
    sql = 'SELECT * FROM pokemon WHERE id=$1 ;'
    result = query(sql, id)

    pokemon_to_h(result.first)
  end

  def submit_user_data(ratings)
    ratings.each { |id, rating| insert_one_rating(id, rating) }
  end

  def load_all_ratings
    # FIXME: write method
    # -- display all pokemon ids, names, img, alongside their no. of ratings of each value
    # -- id  | name     | imgname       | ratings_count | avg_rating | cum_rating | ...
    # -- 015 | Beedrill | 015-Bee...png |             2 |        1.5 |          4 | ...

    # SELECT * FROM pokemon AS p
    #   INNER JOIN ratings AS r ON p.id = r.pokemon_id
    #   GROUP BY p.id ;
  end

  private

  def insert_one_rating(id, rating)
    sql = 'INSERT INTO ratings (pokemon_id, rating) VALUES ($1, $2);'
    query(sql, id, rating)
  end

  def query(sql, *args)
    @logger.info "#{sql}: #{args}"
    @db.exec_params(sql, args)
  end

  def pokemon_to_h(row)
    { number: row['id'],
      name: row['name'],
      img: row['imgname'] }
  end
end
