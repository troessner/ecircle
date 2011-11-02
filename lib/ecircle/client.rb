module Ecircle
  class Client
    attr_accessor :auth_token

    def ensuring_logon &block
      begin
        @auth_token ||= logon
      rescue Savon::SOAP::Fault => e
        # If we are here this probably means that our login credentials are wrong.
        response = e.to_hash
        if response[:fault][:faultcode] == 'soapenv:Server.userException' && response[:fault][:detail][:fault][:code] == '502'
          help = <<-doc
          !!!
          Got an authentication exception, chances are good that you're credentials are wrong, so better double check that.
          You can explicitly check for it by calling something like:
          Ecircle.configure do..
          Ecircle.logon
          !!!
          doc
          puts help
        else
          puts "!!! Got an unexpected fault code from Savon: #{response.inspect} !!!"
        end
        raise
      rescue => e
        puts  "!!! Got unexpected non-Savon exception: #{e.class} !!!"
        raise
      end

      first_try = true
      begin
        block.call
      rescue Savon::SOAP::Fault => e
        # If we are here that probably means that our session token has expired.
        if first_try
          first_try = false
          @auth_token = logon
          retry
        else
          puts "!!! Could not re-authenticate after session expired: #{e.to_hash.inspect} !!!"
          raise
        end
      end
    end

    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    def create_member user_id, group_id, invite = false, send_message = false
      ensuring_logon do
        @response = client.request :createMember do
          soap.body = {
            :session     => auth_token,
            :userId      => user_id,
            :groupId     => group_id,
            :invite      => invite.to_s,
            :sendMessage => send_message.to_s
          }
        end
        @response.body[:create_member_response][:create_member_return].to_s
      end
    end

    def create_or_update_user_by_email email
      ensuring_logon do
        @response = client.request :createOrUpdateUserByEmail do
          soap.body = {
            :session     => auth_token, # TODO We can't use @auth_token here cause then the session_id is nil. Why?
            :userXml     => "<user><email>#{email}</email></user>",
            :sendMessage => 0
          }
        end
        @response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_s
      end
    end

    def delete_member member_id
      ensuring_logon do
        @response = client.request :deleteMember do
          soap.body = {
            :session  => auth_token,
            :memberId => member_id
          }
        end
        @response.body[:delete_member_response][:delete_member_return].to_s
      end
    end

    def logon
      @response = client.request :logon do
        soap.body = {
          :user   => Ecircle.configuration.user,
          :realm  => Ecircle.configuration.sync_realm,
          :passwd => Ecircle.configuration.password
        }
      end
      @response.body[:logon_response][:logon_return].to_s
    end

    def send_parametrized_single_message_to_user user_id, message_id, names = [], values = []
      ensuring_logon do
        @response = client.request :sendParametrizedSingleMessageToUser do
          soap.body = {
            :session           => auth_token,
            :singleMessageId   => message_id,
            :userId            => user_id,
            :names             => names,
            :values            => values
          }
        end
      end
    end
  end
end
