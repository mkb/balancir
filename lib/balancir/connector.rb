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

    # Perform HTTP GET request
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

    # Purge request history
    def clear
      @recent_errors = []
      @recent_requests = []
    end

    # Record a response to our request history
    def tally(response)
      @recent_requests << response.error?
      while @recent_requests.length > @failure_ratio.last
        @recent_requests.shift
      end
    end

    # Number of recent requests we know about.
    def request_count
      @recent_requests.count
    end

    # Number of recent errors
    def error_count
      @recent_requests.count(true)
    end

    # Recent errors as a percentage of requests
    def error_rate
      error_count.to_f / request_count
    end

    # Have we exceeded our allowable failure ratio?
    def failed?
      error_count >= @failure_ratio.first
    end
  end
end
