require 'bundler'
Bundler.require :default

dir = File.dirname(__FILE__)

%w!version configuration client!.each do |file|
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

  def method_missing(method, *args, &block)
    client.send method, *args, &block
  end
end
