require 'sinatra'

get '/*' do
  [500, {}, ['Horrible, horrible error.']]
end

run Sinatra::Application
