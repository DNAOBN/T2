require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3",
                                        database: "../database.sqlite3"

class Identidade < ActiveRecord::Base
  belongs_to :discente
end