require 'celluloid'

module Balancir
  # Watches dead connections to see if they come back to life.
  class ConnectionMonitor
    include Celluloid
    attr_accessor :polling_interval_seconds, :ping_path, :revive_threshold
    attr_reader :connectors, :timer

    def initialize(opts)
      @polling_interval_seconds = opts.fetch(:polling_interval_seconds)
      @ping_path = opts.fetch(:ping_path)
      @revive_threshold = opts.fetch(:revive_threshold)
      @connectors = []
    end

    def add_connector(connector)
      raise ArgumentError unless connector.respond_to?(:get)
      @connectors << connector
      @timer = every(@polling_interval_seconds) { self.poll }
    end

    def fire
      @timer.fire
    end

    def poll
      @connectors.each do |c|
        c.get(@ping_path)
      end
    end
  end
end
