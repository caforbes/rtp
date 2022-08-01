# frozen_string_literal: true

require 'pg'
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'yaml'

DB_NAME = 'rtp'
TEST_DB_NAME = 'rtp_test'

# First some helper methods
def db_exist?(dbname)
  connection = PG.connect(dbname: 'template1')
  query = 'SELECT datname FROM pg_database WHERE datistemplate = false;'
  result = connection.exec(query)

  result.field_values('datname').any? { |datname| datname == dbname }
ensure
  connection.close
end

# Define tasks
desc 'Run the main task (tests, testdb teardown, lint)'
task default: %i[test dropdb_test rubocop]

desc 'Run tests with test db'
Rake::TestTask.new do |t|
  t.deps << :makedb_test
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

RuboCop::RakeTask.new

desc 'Make empty dev db'
task makedb: :dropdb do
  sh "createdb #{DB_NAME}"
end

desc 'Drop dev db if it exists'
task :dropdb do
  sh "dropdb #{DB_NAME}" if db_exist?(DB_NAME)
end

desc 'Make empty test db'
task makedb_test: :dropdb_test do
  sh "createdb #{TEST_DB_NAME}"
end

desc 'Drop testdb if it exists'
task :dropdb_test do
  sh "dropdb #{TEST_DB_NAME}" if db_exist?(TEST_DB_NAME)
end

desc 'Setup fresh db with 6 random pokemon'
task setupdb_dev: :makedb do
  main = File.expand_path(__dir__)
  sh "psql -d #{DB_NAME} < #{File.join(main, 'schema.sql')}"

  pokedex = YAML.load_file(File.join(main, 'pokedex.yml'))
  pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }
  pokedex = pokedex.sample(6)

  db = PG.connect(dbname: DB_NAME)
  sql = 'INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);'
  pokedex.each do |pokemon|
    db.exec_params(sql, pokemon)
  end
  db.close
  puts "#{pokedex.size} random pokemon written to db."
end
