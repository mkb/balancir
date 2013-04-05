require 'spec_helper'
require 'balancir/connector'

require 'realweb'

describe Balancir::Connector do
  FIRST_HOST = "http://bbc.com"
  include RealWebHelper

  def creep_clock_forward_seconds(seconds)
    Timecop.freeze(Time.now + seconds)
  end

  before :all do
    ensure_service_running(:fake_service)
  end

  after :all do
    ensure_all_services_stopped
  end

  describe '#get' do
    context 'with a working server' do
      before do
        @connector = connector_for_service(:fake_service)
        @response = @connector.request(:method => :get, :path =>  OK_PATH)
      end

      it 'returns a response object' do
        @response.should respond_to(:status)
        @response.should respond_to(:headers)
        @response.should respond_to(:body)
        @response.should respond_to(:exception)
      end
    end

    context 'when an exception is raised' do
      class CheezburgerError < StandardError; end

      before do
        @connector = Balancir::Connector.new(CONNECTOR_CONFIG)
        excon = double('excon')
        excon.stub(:request).and_raise(Excon::Errors::Error)
        @connector.connection = excon
      end

      it 'does not blow up' do
        expect { @connector.request(:method => :get, :path =>  SOME_PATH) }.to_not raise_error
      end

      it 'returns a response with an exception' do
        @response = @connector.request(:method => :get, :path =>  SOME_PATH)
        @response.should respond_to(:status)
        @response.should respond_to(:headers)
        @response.should respond_to(:body)
        @response.exception.should_not be_nil
        @response.exception.should be_a_kind_of(Excon::Errors::Error)
      end
    end
  end

  describe 'request and error counting' do
    before :each do
      @connector = connector_for_service(:fake_service)
    end

    it 'counts one error for each failed invocation' do
      5.times do |index|
        response = @connector.request(:method => :get, :path =>  BARF_PATH)
        response.should be_error
        @connector.error_count.should eq(index+1)
      end
    end

    it 'knows how many requests were made' do
      5.times do |index|
        response = @connector.request(:method => :get, :path =>  BARF_PATH)
        @connector.request_count.should eq(index+1)
      end
    end

    it 'knows what percentage of calls failed' do
      @connector.request(:method => :get, :path =>  BARF_PATH)
      @connector.error_rate.should eq(1)
      @connector.request(:method => :get, :path =>  OK_PATH)
      @connector.error_rate.should eq(0.5)
      @connector.request(:method => :get, :path =>  OK_PATH)
      @connector.error_rate.should be_within(0.01).of(0.33)
    end

    it 'tracks only enough requests to calculate failure ratio' do
      20.times do
        @connector.request(:method => :get, :path =>  OK_PATH)
      end
      @connector.request_count.should <= @connector.failure_ratio.last
    end
  end

  describe '#failed?' do
    before :each do
      @connector = connector_for_service(:fake_service)
      @connector.request(:method => :get, :path =>  OK_PATH)
      4.times { @connector.request(:method => :get, :path =>  BARF_PATH) }
    end

    it 'indicates not failed before threshold is met' do
      @connector.should_not be_failed
    end

    it 'indicates failed once threshold is met' do
      @connector.request(:method => :get, :path =>  BARF_PATH)
      @connector.should be_failed
    end
  end
end
