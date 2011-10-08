module Ecircle
  class Client
    attr_reader :session_token

    LoginFailed = Class.new(RuntimeError)

    def initialize
      @session_token = nil
    end

    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    def logon
      @session_token = (client.request :logon do
        soap.body = {
          :user => Ecircle.configuration.user,
          :realm => Ecircle.configuration.realm,
          :passwd => Ecircle.configuration.password
        }
      end).body[:logon_response][:logon_return].to_s
    rescue Savon::SOAP::Fault => e
      @session_token = nil
      raise LoginFailed, "Msg: #{e.message}"
    end
  end
end
