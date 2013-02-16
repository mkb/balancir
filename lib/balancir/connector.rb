require 'excon'
require 'balancir/response'

module Balancir
  # Represents a connection to a particular server
  class Connector
    attr_accessor :connection, :random, :recent_errors, :recent_requests

    def initialize(opts)
      @connection = Excon.new(opts.fetch(:url))
      @error_window_seconds = opts.fetch(:error_window_seconds)
      clear
    end

    def get(path)
      response = Response.new()
      recent_requests << Time.now
      raw_response = @connection.request(:method => "GET", :path => 'ok')
      response.parse(raw_response)
      response
    rescue Excon::Errors::Error => e
      response.exception = e
    ensure
      response
    end

    def clear
      @recent_errors = []
      @recent_requests = []
    end

    def request_count
      clear_expired_tallies
      @recent_requests.count
    end

    def record_error
      @recent_errors << Time.now
    end

    def error_count
      clear_expired_tallies
      @recent_errors.count
    end

    def error_rate
      @recent_errors.count.to_f / @recent_requests.count
    end

    def clear_expired_tallies
      [@recent_requests, @recent_errors].each do |tally|
        while expired?(tally.first)
          tally.shift
        end
      end
    end

    private

    def expired?(item)
      item and item < (Time.now - @error_window_seconds)
    end
  end
end
