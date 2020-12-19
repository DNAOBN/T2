require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3",
                                        database: "../database.sqlite3"

class Disciplina < ActiveRecord::Base
  has_and_belongs_to_many :discentes, -> { distinct }
  belongs_to :docente
  before_destroy { discentes.clear }
end