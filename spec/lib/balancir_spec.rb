require 'spec_helper'
require 'helpers/realweb_helpers'
require 'balancir'

class FakeRandom2
  def initialize
    @array = [0, 99]
    @index = 0
  end
  
  def rand(a)
    @index += 1
    @index = 0 if @index >= @array.size
    return @array[@index]
  end
end

describe Balancir do
  include RealWebHelpers

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
        ensure_service_running('fake_service', 0)
        ensure_service_running('fake_service', 1)

        @service_one = service('fake_service', 0)
        @service_two = service('fake_service', 1)

        random = FakeRandom2.new
        @config = BALANCIR_CONFIG.merge(:endpoints =>
          [{ :url => url_for_service('fake_service', 0)},
          {:url => url_for_service('fake_service', 1)}],
          :random_source => lambda { random.rand(100) })
        reset_fakes

        @balancir = Balancir.new(@config)
        2.times do
          @balancir.request(method:'GET', path:'/ok')
        end
      end

      it 'sends one request to each backend' do
        count(0).should eq(1)
        count(1).should eq(1)
      end
    end
  end
end
