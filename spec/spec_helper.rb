$: << './lib'
require 'awesome_print'

SOME_PATH = '/stuff/and/things'
OK_PATH = '/ok'
BARF_PATH = '/barf'
PING_PATH = '/ping'
CONNECTOR_CONFIG = {:url => "https://whatever.net",
                    :failure_ratio => [5,10]}

RESPONSE_FIELDS = {:headers => {"Content-Type"=>"application/json",
                                "Content-Length"=>"31",
                                "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2012-11-10)",
                                "Date"=>"Fri, 15 Feb 2013 04:20:31 GMT",
                                "Connection"=>"Keep-Alive"}, :body => %q|{"tacos":{"cheese":"cheddar"}}}|, :status => 200}

def successful_response
  raw_response = stub(RESPONSE_FIELDS)
  response = Balancir::Response.new
  response.parse(raw_response)
  response
end

def failed_response
  response = Balancir::Response.new
  response.exception = StandardError.new
  response
end


