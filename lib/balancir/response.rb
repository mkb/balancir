module Balancir
  class Response
    attr_accessor :body, :status, :headers, :exception

    def parse(raw_response)
      @headers = raw_response.headers
      @body = raw_response.body
      @status = raw_response.status.to_i
    end

    def error?
      return true if @exception
      return true if (500..599).include?(status)
      return false
    end

    def successful?
      !error?
    end
  end
end
