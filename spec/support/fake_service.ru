require 'sinatra'

SOME_JSON = %Q|{"tacos":{"cheese":"cheddar"}}}|
get '/ok' do
  [200, { 'Content-Type' => 'application/json' }, [SOME_JSON]]
end

get '/barf' do
  raise "I'm in yr base killin yr dudes."
end

run Sinatra::Application

