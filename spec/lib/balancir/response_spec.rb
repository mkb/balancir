require 'spec_helper'
require 'balancir/response'

describe Balancir::Response do
  ERROR_STATUSES = (500..511).to_a + [598, 599]

  RESPONSE_FIELDS = {:headers => {"Content-Type"=>"application/json",
                                  "Content-Length"=>"31",
                                  "Server"=>"WEBrick/1.3.1 (Ruby/1.9.3/2012-11-10)",
                                  "Date"=>"Fri, 15 Feb 2013 04:20:31 GMT",
                                  "Connection"=>"Keep-Alive"}, :body => %q|{"tacos":{"cheese":"cheddar"}}}|, :status => 200}

  def successful_response
    raw_response = stub(RESPONSE_FIELDS)
    response = Balancir::Response.new
    response.parse(raw_response)
    response
  end

  describe 'basic response parsing' do
    before do
      @response = successful_response
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

  describe 'error detection' do
    it 'treats exceptions as errors' do
      response = successful_response
      response.exception = StandardError.new

      response.should be_error
    end

    it 'counts 500s as errors' do
      ERROR_STATUSES.each do |status|
        raw_response = stub(RESPONSE_FIELDS.merge(:status => status))
        response = Balancir::Response.new
        response.parse(raw_response)
        response.should be_error
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
