require 'excon'
require 'balancir/response'

module Balancir
  # Represents a connection to a particular server
  class Connector
    attr_accessor :connection, :random, :recent_errors, :recent_requests

    def initialize(host)
      @connection = Excon.new(host)
      clear
    end

    def get(path)
      response = Response.new()
      recent_requests << true
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
      @recent_requests.count
    end

    def record_error
      @recent_errors << true
    end

    def error_count
      @recent_errors.count
    end

    def error_rate
      @recent_errors.count.to_f / @recent_requests.count
    end
  end
end
