require 'spec_helper'
require 'balancir'
describe Balancir do
  ENDPOINT_ONE = {:url => 'https://tacos-east.monkey.mk', :weight => 50 }
  ENDPOINT_TWO = {:url => 'https://tacos-west.monkey.mk', :weight => 50 }
  BALANCIR_CONFIG = {:endpoints => [ENDPOINT_ONE, ENDPOINT_TWO],
                     :failure_ratio => [3,10],
                     :polling_interval_seconds => 5,
                     :ping_path => '/ping',
                     :revive_threshold => [10,10] }

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
      monitor = @balancir.connection_monitor
      monitor.should be_alive
      monitor.distributor.should eq(@balancir.distributor)
    end
  end

  describe '#request' do
    context 'with two endpoints' do
      before do
      end
    end
  end
end
