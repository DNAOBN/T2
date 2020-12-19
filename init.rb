require 'rubygems'
require 'active_record'
require './models/discente.rb'
require './models/docente.rb'
require './models/disciplina.rb'
require './models/identidade.rb'

ActiveRecord::Base.establish_connection :adapter => "sqlite3",
                                        :database => "database.sqlite3"

ActiveRecord::Base.connection.create_table :docentes do |c|
  c.string :nome
  c.references :disciplina, foreign_key: true
end

ActiveRecord::Base.connection.create_table :discentes do |c|
  c.string :nome
  c.references :disciplina
  c.references :identidade, foreign_key: true
end

ActiveRecord::Base.connection.create_table :disciplinas do |c|
  c.string :nome
  c.integer :carga_horaria
  c.references :discente
  c.references :docente, foreign_key: true
end

ActiveRecord::Base.connection.create_table :discentes_disciplinas, id: false do |c|
  c.references :discente, :unique => true
  c.references :disciplina, :unique => true
end

ActiveRecord::Base.connection.create_table :identidades do |c|
  c.string :grr
  c.string :cpf
  c.references :discente, foreign_key: true
end