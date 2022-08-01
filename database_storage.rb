# frozen_string_literal: true

require 'pg'

DB_NAME = 'rtp'

# for handling connection to db and submission of ratings
class DatabaseStorage
  def initialize(logger)
    @is_test = (ENV['RACK_ENV'] == 'test')
    @db = PG.connect(dbname: dbname)
    @logger = logger
    setup_schema
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

  def dbname
    if Sinatra::Base.production?
      ENV['DATABASE_URL']
    elsif @is_test # TODO: setup test db
      "#{DB_NAME}_test"
    else
      DB_NAME
    end
  end

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

  def setup_schema
    return if schema_exists?

    schema = File.join(File.expand_path(__dir__), 'schema.sql')
    @db.exec IO.read(schema)
    seed_db
  end

  def schema_exists?
    sql = <<~SQL
      SELECT COUNT(*) FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'pokemon';
    SQL

    result = query(sql)
    result[0]['count'] == '1'
  end

  def seed_db
    pokedex_path = if @is_test
                     File.join(File.expand_path(__dir__), 'test', 'pokedex.yml')
                   else
                     File.join(File.expand_path(__dir__), 'pokedex.yml')
                   end
    pokedex = YAML.load_file(pokedex_path)
    pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }

    sql = 'INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);'
    pokedex.each { |pokemon| query(sql, *pokemon) }
  end
end
