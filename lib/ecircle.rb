Bundle.require :default

require "ecircle/version"

module Ecircle
  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  def configure &block
    configuration.instance_eval(block)
  end
end
