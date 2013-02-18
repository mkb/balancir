require 'sinatra'
require 'logger'

FileUtils.mkdir_p('log')
log = Logger.new('log/fake_service.log')

SOME_JSON = %Q|{"tacos":{"cheese":"cheddassssssssssr"}}}|
get '/ok' do
  log.debug('/ok')
  [200, { 'Content-Type' => 'application/json' }, [SOME_JSON]]
end

get '/barf' do
  log.debug('/barf')
  raise "I'm in yr base killin yr dudes."
end

get '/*' do
  log.debug('/nada')
  [404, {}, ['Not found.']]
end

run Sinatra::Application

