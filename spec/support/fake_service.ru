require 'sinatra'
require 'logger'

class FakeService < Sinatra::Base
  def initialize(*argv)
    FileUtils.mkdir_p('log')
    @log = Logger.new('log/fake_service.log')
    super
  end

  SOME_JSON = %Q|{"tacos":{"cheese":"cheddar"}}}|
  get '/ok' do
    @log.debug('/ok')
    [200, { 'Content-Type' => 'application/json' }, [SOME_JSON]]
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
