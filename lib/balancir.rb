require 'balancir/version'
require 'balancir/distributor'
require 'balancir/connector'
require 'balancir/connection_monitor'

class Balancir
  attr_accessor :distributor, :failure_ratio, :connection_monitor

  def initialize(config = nil)
    if config
      configure(config)
    end
  end

  def configure(config)
    @distributor = Distributor.new
    @connection_monitor = ConnectionMonitor.new(@distributor, config)
    @failure_ratio = config.fetch(:failure_ratio)
    config[:endpoints].each do |endpoint|
      weight = endpoint.delete(:weight)
      endpoint[:failure_ratio] = @failure_ratio
      connector = Connector.new(endpoint)
      @distributor.add_connector(connector, weight)
    end
  end
end
