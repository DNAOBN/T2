require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3",
                                        database: "../database.sqlite3"

class Docente < ActiveRecord::Base
  has_many :disciplinas
end