require 'spec_helper'
require 'balancir/connection_monitor'
require 'balancir/connector'

describe Balancir::ConnectionMonitor do
  MONITOR_CONFIG = { :polling_interval_seconds => 5,
                     :ping_path => "/ping",
                     :revive_threshold => [10,10] }

  describe '#initialize' do
    before do
      @monitor = Balancir::ConnectionMonitor.new(MONITOR_CONFIG)
    end

    it 'sets a polling interval' do
      @monitor.polling_interval_seconds.should eq(5)
    end

    it 'sets a ping path' do
      @monitor.ping_path.should eq('/ping')
    end

    it 'sets a revive threshold' do
      @monitor.revive_threshold.should eq([10,10])
    end
  end

  describe '#add_connector' do
    before do
      @monitor = Balancir::ConnectionMonitor.new(MONITOR_CONFIG)
      @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
      @monitor.add_connector(@connector)
    end

    it 'records the connection addred' do
      @monitor.connectors.count.should eq(1)
    end

    it 'starts a timer' do
      @monitor.timer.interval.should eq(MONITOR_CONFIG[:polling_interval_seconds])
    end
  end

  describe 'timer' do
    before do
      @monitor = Balancir::ConnectionMonitor.new(MONITOR_CONFIG)
      @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
      @monitor.add_connector(@connector)
    end

    it 'calls #poll when triggered' do
      # Celluloid#wrapped_object lets rspec expectations work with cellulooid proxying
      @monitor.wrapped_object.should_receive(:poll)
      @monitor.fire
    end

    it 'repeats' do
      @monitor.timer.recurring.should be_true
      @monitor.fire
    end
  end

  # Can we probe that timer events won't pile up if polling is low?

  describe '#poll' do
    before do
      @monitor = Balancir::ConnectionMonitor.new(MONITOR_CONFIG)
      @connector_a = Balancir::Connector.new(:url => 'https://first-cluster.mycompany.com',
                                             :failure_ratio => [5,10])
      @connector_b = Balancir::Connector.new(:url =>'https://second-cluster.mycompany.com',
                                             :failure_ratio => [5,10])
      @monitor.add_connector(@connector_a)
      @monitor.add_connector(@connector_b)
    end

    it 'tries each connection' do
      @connector_a.should_receive(:get).with(PING_PATH)
      @connector_b.should_receive(:get).with(PING_PATH)
      @monitor.fire
    end

    pending 'does not notify the distrubutor before the revive threshold is reached' do
      @connector_a.stub(:get).with(PING_PATH).and_return(successful_response)
      @connector_b.stub(:get).with(PING_PATH).and_return(failed_response)
    end

    pending 'notifies the distributor when a connection comes back to life' do
      @connector_a.stub(:get).with(PING_PATH).and_return(successful_response)
      @connector_b.stub(:get).with(PING_PATH).and_return(failed_response)
    end
  end
end

[:<,
 :<=,
 :>,
 :>=,
 :between?,
 :call,
 :cancel,
 :fire,
 :interval,
 :recurring,
 :reset,
 :time]
