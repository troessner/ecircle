source 'http://rubygems.org'

gem 'rake'
gem 'savon', '0.9.7'

group :test do
  gem 'rspec', '2.6.0'
end

gemspec

# Normally we would add all necessary gems to the gemspec and none here. However, in this case
#   Bundler.require(:default)
# doesn't fail but doesn't require the gems as well.
# So why do we still need the 'gemspec' here? Because of:
#   $:.push File.expand_path("../lib", __FILE__)
# TODO -> Improve me.
