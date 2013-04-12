$: << './lib'
$: << './spec'

require 'awesome_print'
require 'colorize'
begin
  require 'pry'
rescue LoadError
  # Alas.
end

SOME_PATH = '/stuff/and/things'
OK_PATH = '/ok'
BARF_PATH = '/barf'
PING_PATH = '/ping'
ENDPOINT_ONE = {:url => 'https://tacos-east.monkey.mk', :weight => 50 }
ENDPOINT_TWO = {:url => 'https://tacos-west.monkey.mk', :weight => 50 }


CONNECTOR_CONFIG = {:url => "https://whatever.net",
                    :failure_ratio => [5,10]}
MONITOR_CONFIG = { :polling_interval_seconds => 5,
                   :ping_path => "/ping",
                   :revive_threshold => [10,10] }
BALANCIR_CONFIG = {:endpoints => [ENDPOINT_ONE, ENDPOINT_TWO]}.
  merge(CONNECTOR_CONFIG).merge(MONITOR_CONFIG)

RESPONSE_FIELDS = {
  :headers => {"Content-Type"=>"application/json",
               "Content-Length"=>"31",
               "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2012-11-10)",
               "Date"=>"Fri, 15 Feb 2013 04:20:31 GMT",
               "Connection"=>"Keep-Alive"},
:body => %q|{"tacos":{"cheese":"cheddar"}}}|,
  :status => 200 }

