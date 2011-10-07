module Ecircle
  class Configuration
    WSDL     = 'http://webservices.ecircle-ag.com/soap/ecm.wsdl'
    ENDPOINT = 'http://webservices.ecircle-ag.com/rpc'

    attr_accessor :user, :password, :wsdl, :endpoint

    def initialize
      wsdl     = WSDL
      endpoint = ENDPOINT
    end
  end
end
