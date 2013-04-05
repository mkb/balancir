require 'celluloid'

class Balancir
  # Watches dead connections to see if they come back to life.
  class ConnectionMonitor
    include Celluloid
    attr_accessor :polling_interval_seconds, :ping_path, :revive_threshold
    attr_reader :distributor, :responses, :timer

    def initialize(distributor, opts)
      @distributor = distributor
      @polling_interval_seconds = opts.fetch(:polling_interval_seconds)
      @ping_path = opts.fetch(:ping_path)
      @revive_threshold = opts.fetch(:revive_threshold)
      @responses = {}
    end

    # Start monitoring another connection
    def add_connector(connector)
      raise ArgumentError unless connector.respond_to?(:request)
      @responses[connector] = []
      @timer = every(@polling_interval_seconds) { poll }
    end

    # Fire the timer. (This is here to facilitate testing.)
    def _fire
      @timer.fire
    end

    def poll
      @responses.keys.each do |c|
        response = c.request(:method => :get, :path => @ping_path)
        tally_response(c, response)
        if revive_threshold_met?(c)
          reactivate(c)
        end
      end
    end

    def reactivate(connector)
      @distributor.add_connector(connector)
      @responses.delete(connector)
    end

    def tally_response(connector, response)
      @responses[connector] << response.successful?
      while @responses[connector].length > @revive_threshold.last
        @responses[connector].shift
      end
    end

    def revive_threshold_met?(connector)
      @responses[connector].count(true) >= @revive_threshold.first
    end

    def connectors
      @responses.keys
    end
  end
end
