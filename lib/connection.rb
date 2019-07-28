require 'pg'

module Events
  class << self
    attr_accessor :connection
  end
end

Events.connection = PG::Connection.open(dbname: 'events')
