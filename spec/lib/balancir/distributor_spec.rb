require 'spec_helper'
require 'unnamed/distributor'
require 'unnamed/connector'

describe Unnamed::Distributor do
  SOME_PATH = '/stuff/and/things'
  ERROR_STATUSES = (500..511).to_a + [598, 599]

  context 'with a single connector' do
    before do
      @connector = Unnamed::Connector.new
      @distributor = Unnamed::Distributor.new
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

  pending 'with a single, failed connector' do
    it 'raises Unnamed::NoConnectorsAvailable when called'
    it 'tests the failed connector'
    it 'reenables the failed connecor when it comes back'
  end

  context 'with two well-behaved connectors' do
    it 'distributes calls between them'
  end

  pending 'with two connectors, one well-behaved, one not' do
    it 'tolerates occasional errors'
    it 'disables a failing connector'
    it 're-enables a failed connector which resumes working'
  end

  # what about notifications?
end
