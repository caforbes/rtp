# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
require 'yaml'
require 'pg'
require 'rubocop/rake_task'

desc 'Run the main task (tests, lint)'
task default: [:test, :rubocop]

desc 'Run tests'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

RuboCop::RakeTask.new

desc 'Make empty db from schema'
task makedb: :dropdb do
  main = File.expand_path(__dir__)
  sh 'createdb rtp'
  sh "psql -d rtp < #{File.join(main, 'schema.sql')}"
end

desc 'Drop db if it exists'
task :dropdb do
  # check connection first
  PG.connect(dbname: 'rtp').close
  sh 'dropdb rtp'
rescue PG::ConnectionBad
end

desc 'Setup fresh db with all pokemon'
task setupdb: :makedb do
  main = File.expand_path(__dir__)
  pokedex = YAML.load_file(File.join(main, 'pokedex.yml'))
  pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }

  db = PG.connect(dbname: 'rtp')
  sql = 'INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);'
  pokedex.each do |pokemon|
    db.exec_params(sql, pokemon)
  end
  db.close
  puts "#{pokedex.size} pokemon written to db."
end

desc 'Setup fresh db with 6 random pokemon'
task setupdb_sample: :makedb do
  main = File.expand_path(__dir__)
  pokedex = YAML.load_file(File.join(main, 'pokedex.yml'))
  pokedex.map! { |pokemon| [pokemon[:number], pokemon[:name], pokemon[:img]] }
  pokedex = pokedex.sample(6)

  db = PG.connect(dbname: 'rtp')
  sql = 'INSERT INTO pokemon (id, name, imgname) VALUES ($1, $2, $3);'
  pokedex.each do |pokemon|
    db.exec_params(sql, pokemon)
  end
  db.close
  puts "#{pokedex.size} random pokemon written to db."
end
