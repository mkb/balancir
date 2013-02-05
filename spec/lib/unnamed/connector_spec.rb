require 'spec_helper'
require 'realweb'
require 'unnamed/connector'

describe Unnamed::Connector do
  before :all do
    fake_server = File.expand_path('./spec/support/fake_working_service.ru')
    @server = RealWeb.start_server_in_thread(fake_server)
  end

  after :all do
    @server.stop
  end

  pending 'error recording'
  # need to support HMAC
end
