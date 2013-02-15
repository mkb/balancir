source 'https://rubygems.org'
gemspec

group :localdev do
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'growl', :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem 'pry'
  gem 'pry-debugger'
  gem 'guard'
  gem 'guard-rspec'
  gem 'travis-lint'
  gem 'awesome_print'
end
