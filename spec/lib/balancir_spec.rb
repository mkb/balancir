require 'spec_helper'
require 'balancir'
describe Balancir do
  before do
    @balancir = Balancir.new(BALANCIR_CONFIG)
  end

  describe '#configure' do
    it 'sets failure_ratio' do
      @balancir.failure_ratio.should eq BALANCIR_CONFIG[:failure_ratio]
    end

    it 'instantiates a distributor' do
      @balancir.distributor.should respond_to(:request)
    end

    it 'tells the distributor about the connectors' do
      @connectors = @balancir.distributor.active_connectors
      @bases = @connectors.map(&:url)
      @bases.should =~ [ENDPOINT_ONE[:url], ENDPOINT_TWO[:url]]
    end

    it 'instantiates a connection monitor' do
      @balancir.connection_monitor.should respond_to(:add_connector)
      @balancir.connection_monitor.should be_alive
    end
  end

  describe '#request' do
    it 'performs a GET'
    it 'performs a POST'
  end
end
