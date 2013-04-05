$: << './lib'
require 'awesome_print'
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

module ResponseUtils
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
end


module RealWebHelper
  def ensure_service_running(service_name, index = 0)
    @services ||= {}
    unless service(service_name, index) and
      service(service_name, index).running?
      full_path = File.expand_path("./spec/support/#{service_name}.ru")
      service = nil
      if RUBY_PLATFORM == 'java'
        service = RealWeb.start_server_in_thread(full_path)
      else
        service = RealWeb.start_server(full_path)
      end
    end

    add_service(service_name, index, service)
    service(service_name, index).should be_running
  end

  def service(service_name, index = 0)
    @services[service_name.to_s + index.to_s]
  end

  def add_service(service_name, index, service)
    @services[service_name.to_s + index.to_s] = service
  end

  def ensure_all_services_stopped
    @services.values.each do |service|
      begin
        service.stop
      rescue => e
        warn "Exception while stopping service:"
        ap e.backtrace
      end
    end
  end

  def url_for_service(service_name, index = 0)
    port = service(service_name, index).port
    "http://127.0.0.1:#{port}"
  end

  def connector_for_service(service_name, index = 0)
    service(service_name, index).should be_running
    Balancir::Connector.new(:url  => url_for_service(service_name, index),
                            :failure_ratio => [5,5])
  end
end
