module Balancir
  # Represents a response from an HTTP call.
  class Response
    attr_accessor :body, :status, :headers, :exception

    def parse(raw_response)
      @headers = raw_response.headers
      @body = raw_response.body
      @status = raw_response.status.to_i
    end

    def error?
      !successful?
    end

    def successful?
      return false if exception
      return true if [200, 307, 404, 410].include?(status)
      return true if (300..305).include?(status)
      return false
    end
  end
end
