module Balancir
  # Represents a connection to a particular server
  class Connector
    attr_accessor :connection, :random, :recent_errors

    def clear_errors
      @recent_errors = []
    end

    def record_error
      @recent_errors << true
    end
  end
end
