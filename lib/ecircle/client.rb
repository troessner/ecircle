module Ecircle
  class Client
    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    def create_member user_id, group_id, invite = false, sendMessage = false
      session_id = logon
      @response = client.request :createMember do
        soap.body = {
          :session     => session_id,
          :userId      => user_id,
          :groupId     => group_id,
          :invite      => 0,
          :sendMessage => 0
        }
      end
      @response.body[:create_member_response][:create_member_return].to_s
    end

    def create_or_update_user_by_email email
      session_id = logon
      @response = client.request :createOrUpdateUserByEmail do
        soap.body = {
          :session     => session_id,
          :userXml     => "<user><email>#{email}</email></user>",
          :sendMessage => 0
        }
      end
      @response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_s
    end

    def delete_member member_id
      session_id = logon
      @response = client.request :deleteMember do
        soap.body = {
          :session  => session_id,
          :memberId => member_id
        }
      end
      @response.body[:delete_member_response][:delete_member_return].to_s
    end

    def logon
      @response = client.request :logon do
        soap.body = {
          :user   => Ecircle.configuration.user,
          :realm  => Ecircle.configuration.realm,
          :passwd => Ecircle.configuration.password
        }
      end
      @response.body[:logon_response][:logon_return].to_s
    end

    def send_parametrized_single_message_to_user user_id, message_id, names = [], values = []
      @response = client.request :sendParametrizedSingleMessageToUser do
        soap.body = {
          :session           => logon,
          :singleMessageId   => message_id,
          :userId            => user_id,
          :names             => names,
          :values            => values
        }
      end
    end
  end
end
