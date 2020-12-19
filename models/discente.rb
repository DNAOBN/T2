require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3",
                                        database: "../database.sqlite3"

class Discente < ActiveRecord::Base
  has_and_belongs_to_many :disciplinas, -> { distinct }
  has_one :identidade
  before_destroy { disciplinas.clear }
end