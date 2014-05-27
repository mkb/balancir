require 'realweb'
require 'json'

if ENV['CI'] and ENV['CI'] == 'true'
  puts "Rocking the Travs action.".light_blue
  REALWEB_OPTIONS = { :timeout => 20, :verbose => true }
else
  REALWEB_OPTIONS = { :timeout => 20 }
end


module RealWebHelpers
  def ensure_service_running(service_name, index = 0)
    @services ||= {}
    unless service(service_name, index) and
      service(service_name, index).running?
      full_path = File.expand_path("./spec/support/#{service_name}.ru")
      service = nil
      if RUBY_PLATFORM == 'java'
        service = RealWeb.start_server_in_thread(full_path, REALWEB_OPTIONS)
      else
        service = RealWeb.start_server(full_path, REALWEB_OPTIONS)
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

  def reset_fakes
    Excon.get(url_for_service('fake_service', 0) + '/reset')
    Excon.get(url_for_service('fake_service', 1) + '/reset')
  end

  def count(index)
    response = Excon.get(url_for_service('fake_service', index) + '/count')
    parsed = JSON.parse(response.body)
    parsed['tally'].to_i
  end

  def url_for_service(service_name, index = 0)
    port = service(service_name, index).port
    "http://127.0.0.1:#{port}"
  end

  def connector_for_service(service_name, index = 0)
    service(service_name, index).should be_running
    Balancir::Connector.new(:url  => url_for_service(service_name, index),
                            :failure_ratio => [5,5], :weight => 10)
  end
end
