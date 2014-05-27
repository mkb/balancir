source 'https://rubygems.org'
gemspec

group :development do
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'growl', :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem 'pry'
  gem 'pry-debugger' , :platforms => 'ruby_19'
  gem 'guard'
  gem 'guard-rspec'
  gem 'travis-lint'
end
