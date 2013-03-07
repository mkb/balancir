require 'spec_helper'
require 'balancir/connection_monitor'
require 'balancir/connector'
require 'balancir/distributor'

describe Balancir::ConnectionMonitor do
  include ResponseUtils
  MONITOR_CONFIG = { :polling_interval_seconds => 5,
                     :ping_path => "/ping",
                     :revive_threshold => [10,10] }
  PING_PARAMS = {:method => :get, :path => PING_PATH}

  before do
    @distributor = Balancir::Distributor.new
    @monitor = Balancir::ConnectionMonitor.new(@distributor, MONITOR_CONFIG)
    @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
    @monitor.add_connector(@connector)
  end

  describe '#initialize' do
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
    it 'records the connection addred' do
      @monitor.connectors.should have(1).item
    end

    it 'starts a timer' do
      @monitor.timer.interval.should eq(MONITOR_CONFIG[:polling_interval_seconds])
    end
  end

  describe 'timer' do
    it 'calls #poll when triggered' do
      # Celluloid#wrapped_object lets rspec expectations work with cellulooid proxying
      @monitor.wrapped_object.should_receive(:poll)
      @monitor._fire
    end

    it 'repeats' do
      @monitor.timer.recurring.should be_true
      @monitor._fire
    end
  end

  describe '#revive_threshold_met?' do
    context 'with a string of failures' do
      before do
        @response = failed_response
      end

      it 'always returns false' do
        20.times do
          @monitor.tally_response(@connector, @response)
          @monitor.revive_threshold_met?(@connector).should be_false
        end
      end
    end

    context 'with a working connecton' do
      before do
        @response = successful_response
      end

      it 'returns false before threshold is met' do
        9.times do
          @monitor.tally_response(@connector, @response)
          @monitor.revive_threshold_met?(@connector).should be_false
        end
      end

      it 'returns true once threshold is met' do
        10.times do
          @monitor.tally_response(@connector, @response)
        end
        @monitor.revive_threshold_met?(@connector).should be_true
      end
    end

    context 'with an intermittent connecton' do
      before do
        @monitor.revive_threshold = [7,10]
      end

      it 'returns false with enough successes but not enough in a row' do
        responses = [successful_response, successful_response, successful_response,
                     failed_response, failed_response]
        responses.cycle(4) do |r|
          @monitor.tally_response(@connector, r)
          @monitor.revive_threshold_met?(@connector).should be_false
        end
      end

      it 'returns true when the successes proportion is actually met' do
        responses = [successful_response, successful_response, successful_response,
                     failed_response]
        responses.cycle(3) do |r|
          @monitor.tally_response(@connector, r)
        end
        @monitor.revive_threshold_met?(@connector).should be_true
      end
    end
  end

  describe '#poll' do
    before do
      @connector_a = Balancir::Connector.new(:url => 'https://first-environment.mycompany.com',
                                             :failure_ratio => [5,10])
      @connector_b = Balancir::Connector.new(:url =>'https://second-environment.mycompany.com',
                                             :failure_ratio => [5,10])
      @monitor.add_connector(@connector_a)
      @monitor.add_connector(@connector_b)
    end

    it 'tries each connection' do
      @connector_a.should_receive(:request).with(PING_PARAMS).and_return(successful_response)
      @connector_b.should_receive(:request).with(PING_PARAMS).and_return(successful_response)
      @monitor._fire
    end

    context 'with one working connection and one busted' do
      before do
        @connector_a.stub(:request).with(PING_PARAMS).and_return(successful_response)
        @connector_b.stub(:request).with(PING_PARAMS).and_return(failed_response)
      end

      it 'does reactivate the connection before the revive threshold is reached' do
        @monitor.should_not_receive(:reactivate)

        9.times do
          @monitor._fire
        end
      end

      it 'reactivates the connection' do
        @distributor.active_connectors.should be_empty
        @monitor.wrapped_object.should_receive(:reactivate)
        10.times do
          @monitor._fire
        end
      end
    end

    describe '#reactivate' do
      before do
        @monitor.reactivate(@connector)
      end

      it 'notifies the distributor' do
        @distributor.active_connectors.should include(@connector)
      end

      it 'removes the connection from the monitored list' do
        @monitor.connectors.should_not include(@connector)
      end
    end
  end
end

  # timer methods:
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
