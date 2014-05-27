class Balancir
  # Accepts requests and distributes them between connectors.
  class Distributor
    class NoConnectorsAvailable < StandardError; end

    attr_accessor :active_connectors, :failed_connectors

    def initialize(random_source=nil)
      if random_source.nil?
        # Random.rand returns a decimal float, so multiply by 100 and
        # convert to an integer to get an integer
        @random_source = lambda { return (Random.rand*100).to_i }
      else
        @random_source = random_source
      end
      @active_connectors = []
      @failed_connectors = []
      @total_weight = 0
      @ranges = []
    end

    # Place a connector into active rotation
    def add_connector(connector)
      old_weight = @total_weight
      @total_weight += connector.weight
      @ranges << {:connector => connector, :range =>(old_weight..@total_weight)}
      @active_connectors << connector
    end

    # Perform HTTP request
    def request(options)
      raise NoConnectorsAvailable if @active_connectors.empty?

      r = (@random_source.call.to_f*0.01)*@total_weight.to_f
      for range in @ranges
        if range[:range].include?(r.to_i)
          connector = range[:connector]
        end
      end
      response = connector.request(options)
      response
    end
  end
end
