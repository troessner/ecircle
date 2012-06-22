require 'savon'

%w!api version configuration helper job_package wrapped_response!.each do |file|
  require "ecircle/#{file}"
end

module Ecircle
  class InvalidLoginCredentials < StandardError; end

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
