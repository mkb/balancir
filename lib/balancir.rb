require 'balancir/version'
require 'balancir/distributor'
require 'balancir/connector'
require 'balancir/connection_monitor'

class Balancir
  extend Forwardable
  attr_accessor :distributor, :failure_ratio, :connection_monitor
  def_delegator :@distributor, :request


  def initialize(config = nil)
    if config
      configure(config)
    end
  end

  def configure(config)
    @distributor = Distributor.new(config[:random_source])
    @connection_monitor = ConnectionMonitor.new(@distributor, config)
    @failure_ratio = config.fetch(:failure_ratio)
    @connection_monitor = ConnectionMonitor.new(@distributor, config)
    @weight = config.fetch(:weight)
    config[:endpoints].each do |endpoint|
      weight = endpoint.delete(:weight)
      endpoint[:failure_ratio] = @failure_ratio
      endpoint[:weight] = @weight
      connector = Connector.new(endpoint)
      @distributor.add_connector(connector)
    end
  end
end
