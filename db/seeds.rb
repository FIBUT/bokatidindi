# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if ENV['SEED_FROM'] == 'mysql'
  require_relative './seeds/from_mysql.rb'
else
  database  = ActiveRecord::Base.connection.raw_connection.conninfo_hash[:dbname]
  seed_file = File.join(File.dirname(__FILE__), '/seeds/development.sql')
  sh "psql #{database} < #{seed_file}"
end
