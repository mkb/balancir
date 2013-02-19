require 'spec_helper'
require 'balancir/connector'

require 'realweb'


describe Balancir::Connector do
  FIRST_HOST = "http://bbc.com"

  def ensure_service_running(service_name)
    @services ||= {}
    unless @services[service_name] and @services[service_name].running?
      full_path = File.expand_path("./spec/support/#{service_name}.ru")
      if RUBY_PLATFORM == 'java'
        @services[service_name] = RealWeb.start_server_in_thread(full_path)
      else
        @services[service_name] = RealWeb.start_server(full_path)
      end
    end

    @services[service_name].should be_running
  end

  def ensure_all_services_stopped
    @services.values.each do |service|
      begin
        service.stop
      rescue => e
        warn "Exception while stopping service:"
        ap e.backtrace
      end
    end
  end

  def connector_for_service(service_name)
    @services.should have_key(service_name)
    Balancir::Connector.new(:url  => "http://127.0.0.1:#{@services[service_name].port}",
                            :failure_ratio => [5,5])
  end

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
        @response = @connector.get(OK_PATH)
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
        expect { @connector.get(SOME_PATH) }.to_not raise_error
      end

      it 'returns a response with an exception' do
        @response = @connector.get(SOME_PATH)
        @response.should respond_to(:status)
        @response.should respond_to(:headers)
        @response.should respond_to(:body)
        @response.exception.should_not be_nil
        @response.exception.should be_a_kind_of(Excon::Errors::Error)
      end
    end
  end

  describe 'failure detection' do
    before :each do
      @connector = connector_for_service(:fake_service)
    end

    it 'counts one error for each time called' do
      5.times do |index|
        @connector.get(BARF_PATH)
        @connector.error_count.should eq(index+1)
      end
    end

    it 'knows how many requests were made' do
      5.times do |index|
        response = @connector.get(BARF_PATH)
        @connector.request_count.should eq(index+1)
      end
    end

    it 'knows what percentage of calls failed' do
      @connector.get(BARF_PATH)
      @connector.error_rate.should eq(1)
      @connector.get(OK_PATH)
      @connector.error_rate.should eq(0.5)
      @connector.get(OK_PATH)
      @connector.error_rate.should be_within(0.01).of(0.33)
    end
  end
  # need to support HMAC
end
