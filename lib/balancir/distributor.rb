class Balancir
  # Accepts requests and distributes them between connectors.
  class Distributor
    class NoConnectorsAvailable < StandardError; end

    attr_accessor :failed_connectors, :active_connectors, :fault_tolerance

    def initialize
      @active_connectors = []
    end

    # Place a connector into active rotation
    def add_connector(connector, weight)
      @active_connectors << connector
    end

    # Perform HTTP request
    def get(path)
      raise NoConnectorsAvailable if @active_connectors.empty?

      response = @active_connectors.first.get(path)
      @active_connectors.rotate!
      response
    end
  end
end
