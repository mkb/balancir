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

  pending '#poll' do
    it 'tries each connection'
    it 'records success or failutre'
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
