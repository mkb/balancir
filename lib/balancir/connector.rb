require 'excon'
require 'balancir/response'

module Balancir
  # Represents a connection to a particular server, encapsulating the
  # underlying HTTP library.
  class Connector
    attr_accessor :connection, :random, :recent_errors, :recent_requests,
      :failure_ratio

    def initialize(opts)
      @connection = Excon.new(opts.fetch(:url))
      @failure_ratio = opts.fetch(:failure_ratio)
      clear
    end

    def get(path)
      response = Response.new()
      raw_response = @connection.request(:method => "GET", :path => path)
      response.parse(raw_response)
      response
    rescue Excon::Errors::Error => e
      response.exception = e
      response
    ensure
      tally(response)
    end

    def clear
      @recent_errors = []
      @recent_requests = []
    end

    def tally(response)
      @recent_requests << response.error?
      while @recent_requests.length > @failure_ratio.last
        @recent_requests.shift
      end
    end

    def request_count
      @recent_requests.count
    end

    def error_count
      @recent_requests.count(true)
    end

    def error_rate
      error_count.to_f / request_count
    end

    def clear_expired_tallies
      [@recent_requests, @recent_errors].each do |tally|
        # while expired?(tally.first)
        #   tally.shift
        # end
      end
    end

    def healthy?(distributor)
      # returns true if the connector has failed
      if (self.failure_ratio[0] / self.failure_ratio[1]) < distributor.fault_tolerance
        return true
      else
        return false
      end
    end
  end
end
