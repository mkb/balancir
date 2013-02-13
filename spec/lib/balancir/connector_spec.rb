require 'spec_helper'
require 'realweb'
require 'balancir/connector'

describe Balancir::Connector do
  FIRST_HOST = "http://bbc.com"

  before :all do
    fake_server = File.expand_path('./spec/support/fake_working_service.ru')
    @server = RealWeb.start_server_in_thread(fake_server)
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

      it 'sets headers' do
        @response.headers.should_not be_nil
        @response.headers['Content-Length'].should == '31'
      end

      it 'sets body' do
        @response.body.should_not be_nil
        @response.body.should eq(%Q|{"tacos":{"cheese":"cheddar"}}}|)
      end

      it 'sets numeric status'
      it 'does not set an exception'
    end

    context 'when an exception is raised' do
      it 'returns a response with an exception'
    end
  end

  pending 'error recording'
  # need to support HMAC
end
