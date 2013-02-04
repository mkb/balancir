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
      @connectors.first.get(path)
    end
  end
end
