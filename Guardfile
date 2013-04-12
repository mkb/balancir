
guard 'rspec', :cli => "--color --format nested" do
  watch(%r{^spec/(.+)_spec\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})       { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/*})      { 'spec' }
  watch('spec/spec_helper.rb')    { "spec" }
  watch(%r{^spec/helpers/*})      { 'spec' }
end
