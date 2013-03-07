require 'balancir/version'
require 'balancir/distributor'
require 'balancir/connector'

class Balancir
  attr_accessor :distributor, :failure_ratio

  def initialize(config = nil)
    if config
      configure(config)
    end
  end

  def configure(config)
    @distributor = Distributor.new
    @failure_ratio = config.fetch(:failure_ratio)
    config[:endpoints].each do |endpoint|
      weight = endpoint.delete(:weight)
      endpoint[:failure_ratio] = @failure_ratio
      connector = Connector.new(endpoint)
      @distributor.add_connector(connector, weight)
    end
  end

end
