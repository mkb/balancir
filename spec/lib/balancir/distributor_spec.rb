require 'spec_helper'
require 'balancir/distributor'
require 'balancir/connector'

describe Balancir::Distributor do
  SOME_PATH = '/stuff/and/things'
  ERROR_STATUSES = (500..511).to_a + [598, 599]

  before do
    @connector = Balancir::Connector.new
    @distributor = Balancir::Distributor.new
    @response = double(:status => 200)
  end

  context 'with a single connector' do
    before do
      @connector = Balancir::Connector.new
      @distributor = Balancir::Distributor.new
      @distributor.add_connector(@connector, 100)
      @response = double(:status => 200)
    end

    describe 'message passing' do
      it 'passes on calls to #get' do
        @connector.should_receive(:get).and_return(@response)
        @distributor.get(SOME_PATH)
      end

      it 'passes on calls to #post'
      it 'passes on calls to #put'
      it 'passes on calls to #delete'
    end

    describe 'error detection' do
      it 'counts 500s as errors' do
        ERROR_STATUSES.each do |status|
          @connector.clear_errors
          response = double(:status => status)
          @connector.stub(:get).and_return(response)
          @distributor.get(SOME_PATH)
          @connector.recent_errors.count.should eq 1
        end
      end

      pending "more error detection" do
        it 'does not count 404 or 410 as errors'
        it 'counts other 400s as errors'
        it 'counts 700s as errors'

        it 'counts Errno::ECONNRESET as an error'
        it 'counts Errno::ETIMEDOUT as an error'
        it 'counts Errno::ECONNREFUSED as an error'
        it 'counts Errno::EHOSTUNREACH as an error'
        it 'counts Errno::EAFNOSUPPORT as an error'

        it "disables after enough errors"
      end
    end
  end

  describe 'with a single, failed connector' do
    before do
      @distributor.failed_connectors = [@connector]
      @distributor.active_connectors = []
    end

    it 'raises Balancir::NoConnectorsAvailable when called' do
      expect { @distributor.get(SOME_PATH) }.to raise_error(Balancir::Distributor::NoConnectorsAvailable)
    end

    it 'tests the failed connector'
    it 'reenables the failed connecor when it comes back'
  end

  context 'with two well-behaved connectors' do
    before do
      @connector_a = Balancir::Connector.new
      @connector_b = Balancir::Connector.new
      @distributor.add_connector(@connector_a, 50)
      @distributor.add_connector(@connector_b, 50)
    end

    it 'distributes calls between them' do
      pending
      @connector_a.should_receive(:get).twice.and_return(@response)
      @connector_b.should_receive(:get).twice.and_return(@response)

      4.times do
        @distributor.get(SOME_PATH)
      end
    end
  end

  pending 'with two connectors, one well-behaved, one not' do
    it 'tolerates occasional errors'
    it 'disables a failing connector'
    it 're-enables a failed connector which resumes working'
  end

  # what about notifications?
end
