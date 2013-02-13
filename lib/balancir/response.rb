module Balancir
  class Response
    attr_accessor :body, :status, :headers, :exception

    def initialize(raw_response)
      @headers = raw_response.headers
      @body = raw_response.body
      # @status = raw_response.status
    end
  end
end
