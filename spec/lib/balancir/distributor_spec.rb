require 'spec_helper'
require 'balancir/distributor'
require 'balancir/connector'

class FakeRandom
  def initialize
    @array = [6, 22, 23, 34, 35, 36, 37, 38, 39, 40]
    @index = 0
  end
  
  def rand(a)
    @index += 1
    @index = 0 if @index >= @array.size
    return @array[@index]
  end
end

describe Balancir::Distributor do
  SOME_PARAMS = {:method => :get, :path => SOME_PATH }

  before do
    @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
    @distributor = Balancir::Distributor.new
    @response = double(:status => 200)
  end

  context 'with a single connector' do
    before do
      @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
      @distributor = Balancir::Distributor.new
      @distributor.add_connector(@connector)
      @response = double(:status => 200)
    end

    describe 'message passing' do
      it 'passes on calls to #get' do
        @connector.should_receive(:request).and_return(@response)
        @distributor.request(SOME_PARAMS)
      end

      pending "other http methods" do
        it 'passes on calls to #post'
        it 'passes on calls to #put'
        it 'passes on calls to #delete'
      end
    end
  end

  describe 'with a single, failed connector' do
    before do
      @distributor.failed_connectors = [@connector]
      @distributor.active_connectors = []
    end

    it 'raises Balancir::NoConnectorsAvailable when called' do
      expect { @distributor.request(SOME_PARAMS) }.to raise_error(Balancir::Distributor::NoConnectorsAvailable)
    end
  end

  context 'with two well-behaved connectors' do
    before do
      ary = [5, 5, 80, 81]
      @distributor3 = Balancir::Distributor.new(lambda { ary.pop })
      @connector_a = Balancir::Connector.new(:url => 'https://first-cluster.mycompany.com',
                                             :failure_ratio => [5,10], :weight => 50)
      @connector_b = Balancir::Connector.new(:url =>'https://second-cluster.mycompany.com',
                                             :failure_ratio => [5,10], :weight => 50)
      @distributor3.add_connector(@connector_a)
      @distributor3.add_connector(@connector_b)
    end

    it 'distributes calls between them' do
      @connector_a.should_receive(:request).twice.and_return(@response)
      @connector_b.should_receive(:request).twice.and_return(@response)

      4.times do
        @distributor3.request(SOME_PARAMS)
      end
    end
  end
  
  describe 'distribute load' do
    it 'determines the next connector to use' do
      random = FakeRandom.new
      @distributor2 = Balancir::Distributor.new(lambda { random.rand(100) })
      @connector_a = Balancir::Connector.new(:url => 'https://first-cluster.mycompany.com',
                                             :weight => 10, :failure_ratio => [5,10])
      @connector_b = Balancir::Connector.new(:url => 'https://second-cluster.mycompany.com',
                                             :weight => 20, :failure_ratio => [5,10])
      @connector_c = Balancir::Connector.new(:url => 'https://third-cluster.mycompany.com',
                                             :weight => 70, :failure_ratio => [5,10])
      #@distributor2.active_connectors = [@connector_a, @connector_b, @connector_c]
      @distributor2.add_connector(@connector_a)
      @distributor2.add_connector(@connector_b)
      @distributor2.add_connector(@connector_c)
      @connector_a.should_receive(:request).exactly(1).and_return(@response)
      @connector_b.should_receive(:request).exactly(2).and_return(@response)
      @connector_c.should_receive(:request).exactly(7).and_return(@response)
      
      10.times do
        @distributor2.request(SOME_PATH)
      end
    end
  end

  describe 'with two connectors, one well-behaved, one not' do
    before do
      @connector_a = Balancir::Connector.new(:url => 'https://first-cluster.mycompany.com',
                                             :failure_ratio => [5,10], :weight => 50)
      @connector_b = Balancir::Connector.new(:url =>'https://second-cluster.mycompany.com',
                                             :failure_ratio => [5,10], :weight => 50)
      @distributor.add_connector(@connector_a)
      #@distributor.active_connectors = [@connector_a]
      @distributor.failed_connectors = [@connector_b]
    end

    it 'tolerates occasional errors'
    it 'distributes all calls to the good connector' do
      @connector_a.should_receive(:request).exactly(4).and_return(@response)
      @connector_b.should_not_receive(:request)

      4.times do
        @distributor.request(SOME_PATH)
      end
    end

    it 'disables a failing connector' do
      pending
      @connector_b.failure_ratio = [10, 10]
    end
  end
end
