require 'spec_helper'
require 'balancir/response'
require 'helpers/response_helpers'
require 'excon'


describe Balancir::Response do
  include ResponseHelpers

  FOUR_ERROR_STATUSES = (400..403).to_a + (405..409).to_a + (411..417).to_a
  FIVE_ERROR_STATUSES = (500..511).to_a + [598, 599]
  SEVEN_ERROR_STATUSES = (700..799).to_a
  GOOD_STATUSES = [200, 307, 404, 410] + (300..305).to_a

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
      FIVE_ERROR_STATUSES.each do |status|
        raw_response = double(RESPONSE_FIELDS.merge(:status => status))
        response = Balancir::Response.new
        response.parse(raw_response)
        response.should be_error
      end
    end

    it 'does not count 200, 404, or 410 as errors' do
      GOOD_STATUSES.each do |status|
        raw_response = double(RESPONSE_FIELDS.merge(:status => status))
        response = Balancir::Response.new
        response.parse(raw_response)
        response.should_not be_error
      end
    end

    it 'counts other 400s as errors' do
      FOUR_ERROR_STATUSES.each do |status|
        raw_response = double(RESPONSE_FIELDS.merge(:status => status))
        response = Balancir::Response.new
        response.parse(raw_response)
        response.should be_error
      end
    end

    it 'counts 700s as errors' do
      SEVEN_ERROR_STATUSES.each do |status|
        raw_response = double(RESPONSE_FIELDS.merge(:status => status))
        response = Balancir::Response.new
        response.parse(raw_response)
        response.should be_error
      end
    end

    it 'counts any Errno:: as an error' do
      response = successful_response
      response.exception = Excon::Errors::Error.new
      response.should be_error
    end

    pending "more error detection" do
      it 'counts Errno::ECONNRESET as an error'
      it 'counts Errno::ETIMEDOUT as an error'
      it 'counts Errno::ECONNREFUSED as an error'
      it 'counts Errno::EHOSTUNREACH as an error'
      it 'counts Errno::EAFNOSUPPORT as an error'

      it "disables after enough errors"
    end
  end
end
