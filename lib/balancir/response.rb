module Balancir
  class Response
    attr_accessor :body, :status, :headers, :exception

    def parse(raw_response)
      @headers = raw_response.headers
      @body = raw_response.body
      @status = raw_response.status.to_i
    end
  end
end
