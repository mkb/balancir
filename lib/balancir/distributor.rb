module Unnamed
  # Accepts requests and distributes them between connectors.
  class Distributor

    def initialize
      @connectors = []
    end

    def add_connector(connector, weight)
      @connectors << connector
    end

    def get(path)
      response = @connectors.first.get(path)
      if (500..599).include? response.status
        @connectors.first.record_error
      end
    end
  end
end
