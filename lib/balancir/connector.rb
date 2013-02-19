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
  end
end
