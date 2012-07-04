module Ecircle
  class Configuration
    WSDL      = 'http://webservices.ecircle-ag.com/soap/ecm.wsdl'
    ENDPOINT  = 'http://webservices.ecircle-ag.com/rpc'
    NAMESPACE = "http://webservices.ecircleag.com/rpcns"

    # @private
    attr_accessor :user, :password, :sync_realm, :async_realm, :wsdl, :endpoint, :namespace, :debug

    # @private
    def initialize
      @wsdl      = WSDL
      @endpoint  = ENDPOINT
      @namespace = NAMESPACE
      @debug     = false
    end
  end
end
