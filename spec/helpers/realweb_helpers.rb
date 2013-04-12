require 'realweb'

if ENV['CI'] and ENV['CI'] == 'true'
  puts "Rocking the Travs action.".light_blue
  REALWEB_TIMEOUT = 20
else
  REALWEB_TIMEOUT = 2
end


module RealWebHelpers
  def ensure_service_running(service_name, index = 0)
    @services ||= {}
    unless service(service_name, index) and
      service(service_name, index).running?
      full_path = File.expand_path("./spec/support/#{service_name}.ru")
      service = nil
      if RUBY_PLATFORM == 'java'
        service = RealWeb.start_server_in_thread(full_path,
          :timeout => REALWEB_TIMEOUT)
      else
        service = RealWeb.start_server(full_path,
          :timeout => REALWEB_TIMEOUT)
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

