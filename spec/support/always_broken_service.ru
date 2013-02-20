require 'sinatra'

SOME_JSON = %Q|{"tacos":{"cheese":"cheddar"}}}|
get '/*' do
  [500, {}, ['Horrible, horrible error.']]
end

run Sinatra::Application
