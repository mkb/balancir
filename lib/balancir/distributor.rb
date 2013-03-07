class Balancir
  # Accepts requests and distributes them between connectors.
  class Distributor
    class NoConnectorsAvailable < StandardError; end

    attr_accessor :active_connectors, :failed_connectors

    def initialize
      @active_connectors = []
      @failed_connectors = []
    end

    # Place a connector into active rotation
    def add_connector(connector, weight)
      @active_connectors << connector
    end

    # Perform HTTP request
    def request(options)
      raise NoConnectorsAvailable if @active_connectors.empty?

      response = @active_connectors.first.request(options)
      @active_connectors.rotate!
      response
    end
  end
end
