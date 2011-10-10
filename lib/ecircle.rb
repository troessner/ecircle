require 'bundler'
Bundler.require(:default)

require 'lib/ecircle/version'
require 'lib/ecircle/configuration'
require 'lib/ecircle/client'

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
end
