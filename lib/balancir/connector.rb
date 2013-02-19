require 'excon'
require 'balancir/response'

module Balancir
  # Represents a connection to a particular server
  class Connector
    attr_accessor :connection, :random, :recent_errors, :recent_requests

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
    end

    def request_count
      clear_expired_tallies
      @recent_requests.count
    end

    def error_count
      clear_expired_tallies
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
  end
end
