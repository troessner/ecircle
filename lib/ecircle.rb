require 'bundler'
Bundler.require(:default)

require 'ecircle/version'
require 'ecircle/configuration'
require 'ecircle/client'

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
