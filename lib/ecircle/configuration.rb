module Ecircle
  class Configuration
    WSDL      = 'http://webservices.ecircle-ag.com/soap/ecm.wsdl'
    ENDPOINT  = 'http://webservices.ecircle-ag.com/rpc'
    NAMESPACE = "http://webservices.ecircleag.com/rpcns"

    attr_accessor :user, :password, :realm, :wsdl, :endpoint, :namespace

    def initialize
      @wsdl      = WSDL
      @endpoint  = ENDPOINT
      @namespace = NAMESPACE
    end
  end
end
