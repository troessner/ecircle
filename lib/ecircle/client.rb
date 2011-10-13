module Ecircle
  class Client
    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    def request_session_id
      @response = client.request :logon do
        soap.body = {
          :user   => Ecircle.configuration.user,
          :realm  => Ecircle.configuration.realm,
          :passwd => Ecircle.configuration.password
        }
      end
      @response.body[:logon_response][:logon_return].to_s
    end

    def create_or_update_user_by_email email
      session_id = request_session_id
      @response = client.request :createOrUpdateUserByEmail do
        soap.body = {
          :session     => session_id,
          :userXml     => "<user><email>#{email}</email></user>",
          :sendMessage => 0
        }
      end
      @response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_s
    end

    def look_up_user_by_email email
      session_id = request_session_id
      @response = client.request :lookupUserByEmail do
        soap.body = {
          :session => session_id,
          :email   => email
        }
      end
    end

    def send_parametrized_single_message_to_user user_id, message_id
      session_id = request_session_id
      @response = client.request :sendParametrizedSingleMessageToUser do
        soap.body = {
          :session           => session_id,
          :singleMessageId   => message_id,
          :userId            => user_id
        }
      end
    end
  end
end
