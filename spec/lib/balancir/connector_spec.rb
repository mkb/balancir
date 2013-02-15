require 'spec_helper'
require 'realweb'
require 'balancir/connector'

describe Balancir::Connector do
  FIRST_HOST = "http://bbc.com"

  before :all do
    fake_server = File.expand_path('./spec/support/fake_working_service.ru')
    if RUBY_PLATFORM == "java"
      @server = RealWeb.start_server_in_thread(fake_server)
    else
      @server = RealWeb.start_server(fake_server)
    end

    @server.should_not be_nil
  end

  after :all do
    @server.stop
  end

  describe '#get' do
    context 'with a valid http lib response' do
      before do
        @connector = Balancir::Connector.new("http://127.0.0.1:#{@server.port}")
        @response = @connector.get(SOME_PATH)
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
        @connector = Balancir::Connector.new('http://bogus.server.local')
        excon = double('excon')
        excon.stub(:request).and_raise(Excon::Errors::Error)
        @connector.connection = excon
      end

      it 'does not blow up' do
        expect { @connector.get(SOME_PATH) }.to_not raise_error
      end

      it 'returns a response with an exception' do
        @response = @connector.get(SOME_PATH)
        @response.exception.should_not be_nil
        @response.exception.should be_a_kind_of(Excon::Errors::Error)
      end
    end
  end

  pending 'error recording'
  # need to support HMAC
end
