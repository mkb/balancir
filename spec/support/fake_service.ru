require 'sinatra'
require 'logger'
require 'json'

class FakeService < Sinatra::Base
  def initialize(*argv)
    @@tally = 0
    FileUtils.mkdir_p('log')
    @log = Logger.new('log/fake_service.log')
    super
  end

  SOME_JSON = %Q|{"tacos":{"cheese":"cheddar"}}}|
  get '/ok' do
    @@tally += 1
    @log.debug('/ok')
    [200, { 'Content-Type' => 'application/json' }, [SOME_JSON]]
  end

  get '/reset' do
    @@tally = 0
    @log.debug('/reset')
    [204, {}, []]
  end

  get '/count' do
    @log.debug('/tally')
    [200, { 'Content-Type' => 'application/json' },
      [{:tally => @@tally}.to_json]]
  end

  get '/barf' do
    @log.debug('/barf')
    raise "I'm in yr base killin yr dudes."
  end

  get '/*' do
    @log.debug('/nada')
    [404, {}, ['Not found.']]
  end
end

run FakeService
