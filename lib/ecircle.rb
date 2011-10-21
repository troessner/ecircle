require 'bundler'
require 'active_support/all'
require 'savon'

# TODO Improve requiring of gems.
# `Bundler.require :default` works for an irb session with `require lib/ecircle` (e.g. Savon exists)
# but this won't work from within the rails project since `Bundler.require :default` uses the current rails
# projects Gemfile, not ecircle's one. Not sure if there is a solution for this problem, but I'd
# rather do requires via bundler instead of explicit requires.

dir = File.dirname(__FILE__)

%w!version configuration client helper!.each do |file|
  require File.join(dir, 'ecircle', file)
end

module Ecircle
  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  def client
    @client ||= Client.new
  end

  def configure &block
    block.call configuration
  end

  (Ecircle::Client.instance_methods(false) - [:client]).each do |meth|
    define_singleton_method meth do |*args|
      client.send meth, *args
    end
  end
end
