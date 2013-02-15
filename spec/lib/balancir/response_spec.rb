require 'spec_helper'
require 'balancir/response'

describe Balancir::Response do
  before do
    raw_response = stub(:headers => {"Content-Type"=>"application/json",
   "Content-Length"=>"31",
   "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2012-11-10)",
   "Date"=>"Fri, 15 Feb 2013 04:20:31 GMT",
   "Connection"=>"Keep-Alive"}, :body => %q|{"tacos":{"cheese":"cheddar"}}}|, :status => 200)
    @response = Balancir::Response.new(raw_response)
  end

  it 'sets headers' do
    @response.headers.should_not be_nil
    @response.headers['Content-Length'].should == '31'
  end

  it 'sets body' do
    @response.body.should_not be_nil
    @response.body.should eq(%Q|{"tacos":{"cheese":"cheddar"}}}|)
  end

  it 'sets numeric status' do
    @response.status.should_not be_nil
    @response.status.should eq(200)
  end

  it 'does not set an exception' do
    @response.exception.should be_nil
  end
end
