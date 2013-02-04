require 'spec_helper'
require 'realweb'
require 'unnamed/connector'

describe Unnamed::Connector do
  before :all do
    fake_server = File.expand_path('./spec/support/fake_working_service.ru')
    @server = RealWeb.start_server(fake_server)
  end

  after :all do
    @server.stop
  end

  it 'handles 500'
  it 'handles Errno::ECONNRESET'
end