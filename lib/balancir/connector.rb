require 'excon'
require 'balancir/response'

module Balancir
  # Represents a connection to a particular server
  class Connector
    attr_accessor :connection, :random, :recent_errors

    def initialize(host)
      @connection = Excon.new(host)
    end

    def get(path)
      response = Response.new()
      raw_response = @connection.request(:method => "GET", :path => 'ok')
      response.parse(raw_response)
      response
    rescue Excon::Errors::Error => e
      response.exception = e
    end

    def clear_errors
      @recent_errors = []
    end

    def record_error
      @recent_errors << true
    end
  end
end
