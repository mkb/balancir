require 'sinatra'

SOME_JSON = %Q|{"tacos":{"cheese":"cheddar"}}}|
get '/ok' do
  [200, { 'Content-Type' => 'application/json' }, [SOME_JSON]]
end

run Sinatra::Application

