require 'bundler'
require 'active_support/all'
require 'savon'

# TODO Improve requiring of gems.
# `Bundler.require :default` works for an irb session with `require lib/ecircle` (e.g. Savon exists)
# but this won't work from within the rails project since `Bundler.require :default` uses the current rails
# projects Gemfile, not ecircle's one. Not sure if there is a solution for this problem, but I'd
# rather do requires via bundler instead of explicit requires.

dir = File.dirname(__FILE__)

%w!api version configuration helper job_package wrapped_response!.each do |file|
  require File.join(dir, 'ecircle', file)
end

module Ecircle
  class << self

    #@private
    def configuration
      @configuration ||= Configuration.new
    end

    #@private
    def api
      @api ||= Api.new
    end

    #@private
    def configure &block
      block.call configuration
    end
  end

  (Ecircle::Api.instance_methods(false) - [:client]).each do |meth|
    define_singleton_method meth do |*args|
      api.send meth, *args
    end
  end
end
