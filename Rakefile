require 'rake'
require 'rake/testtask'
require 'yaml'
require 'pg'

desc 'Run the main task (tests)'
task :default => :test

desc 'Run tests'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end

desc 'Remake db from schema, no data'
task :refreshdb do
  main = File.expand_path("..", __FILE__)
  sh 'dropdb rtp'
  sh 'createdb rtp'
  sh "psql -d rtp < #{File.join(main, 'schema.sql')}"
end

desc 'Remake db with all pokemon'
task :cleandb_all => :refreshdb do
  main = File.expand_path("..", __FILE__)
  pokedex = YAML.load_file(File.join(main, 'pokedex.yml'))
  pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }

  db = PG.connect(dbname: 'rtp')
  sql = "INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);"
  pokedex.each do |pokemon|
    db.exec_params(sql, pokemon)
  end
  db.close
  puts "#{pokedex.size} pokemon written to db."
end

desc 'Make new db with 5 random pokemon'
task :cleandb_five => :refreshdb do
  main = File.expand_path("..", __FILE__)
  pokedex = YAML.load_file(File.join(main, 'pokedex.yml'))
  pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }
  pokedex = pokedex.sample(5)

  db = PG.connect(dbname: 'rtp')
  sql = "INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);"
  pokedex.each do |pokemon|
    db.exec_params(sql, pokemon)
  end
  db.close
  puts "#{pokedex.size} random pokemon written to db."
end