require 'spec_helper'
require 'unnamed/distributor'

describe Unnamed::Distributor do
  SOME_PATH = '/stuff/and/things'

  it 'does nothing'

  context 'with a single connector, working fine' do
    before do
      @connector = stub
      @distributor = Unnamed::Distributor.new
      @distributor.add_connector(@connector, 100)
    end

    it 'passes on calls to #get' do
      @connector.should_receive(:get)
      @distributor.get(SOME_PATH)
    end

    it 'passes on calls to #post'
    it 'passes on calls to #put'
    it 'passes on calls to #delete'
  end

  context 'with a single connector misbehaving' do
    # what is the correct behavior? just keep trying?
  end

  context 'with two well-behaved connectors' do
    it 'distributes calls between them'
  end

  context 'with two connectors, one well-behaved, one not' do
    it 'tolerates occasional errors'
    it 'disables a failing connector'
    it 're-enables a failed connector which resumes working'
  end

  # what about notifications?
end
