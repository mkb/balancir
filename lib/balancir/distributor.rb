module Balancir
  # Accepts requests and distributes them between connectors.
  class Distributor
    class NoConnectorsAvailable < StandardError; end

    attr_accessor :failed_connectors, :active_connectors

    def initialize
      @active_connectors = []
    end

    def add_connector(connector, weight)
      @active_connectors << connector
    end

    def get(path)
      raise NoConnectorsAvailable if @active_connectors.empty?

      response = @active_connectors.first.get(path)
      if (500..599).include? response.status
        @active_connectors.first.record_error
      end
    end
  end
end
