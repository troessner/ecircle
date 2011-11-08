module Ecircle
  class Client
    #@private
    attr_accessor :auth_token

    #@private
    def ensuring_logon &block
      begin
        @auth_token ||= logon
      rescue Savon::SOAP::Fault => e
        # If we are here this probably means that our login credentials are wrong.
        response = e.to_hash
        if response[:fault][:detail][:fault][:code] == '502'
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

    # @private
    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    # Creates a member, which basically is just an association between a user and a group.
    #
    # @param [Integer] user_id ecircle user_id
    # @param [Integer] group_id ecircle group_id
    # @param [Boolean] invite send an invite by ecircle
    # @param [Boolean] send_message send a message by ecircle
    # @return [String] the member id
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

    # Create or update user by email
    # see http://developer.ecircle-ag.com/apiwiki/wiki/SynchronousSoapAPI#section-SynchronousSoapAPI-UserObjectExample
    # for an example of the user xml
    # @param [Hash] user_xml, in it's most simple form a { :email => 'test@test.com' } is sufficient
    # @return [Integer] the user id
    def create_or_update_user_by_email attributes
      user_xml = '<user>' + attributes.each_with_object('') do |slice, xml|
        name, value = slice.first, slice.last;
        xml << "<#{name}>#{value}</#{name}>"
      end+'</user>'

      ensuring_logon do
        @response = client.request :createOrUpdateUserByEmail do
          soap.body = {
            :session     => auth_token, # TODO We can't use @auth_token here cause then the session_id is nil. Why?
            :userXml     => user_xml,
            :sendMessage => 0
          }
        end
        @response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_i
      end
    end

    # Delete a member.
    #
    # @param [Integer] group_id ecircle group id
    # @return [WrappedResponse]
    def delete_group group_id
      ensuring_logon do
        # In case we pass in a non existing member id we'll get a corresponding exception, so we need to catch this here as well.
        begin
          @response = client.request :deleteGroup do
            soap.body = {
              :session  => auth_token,
              :memberId => group_id
            }
          end
        rescue Savon::SOAP::Fault => e
          if e.to_hash[:fault][:detail][:fault][:code] == '500'
            # "100" means member ID didn't exist so just return false.
            return WrappedResponse.new(:success => false, :message => e.to_hash[:fault][:detail][:fault][:error_message])
          else
            # Re-raise cause something else went wrong.
            raise
          end
        end
      end
      true
    end

    # Delete a member.
    #
    # @param [Integer] member_id ecircle member id
    # @return [Boolean]
    def delete_member member_id
      ensuring_logon do
        # In case we pass in a non existing member id we'll get a corresponding exception, so we need to catch this here as well.
        begin
          @response = client.request :deleteMember do
            soap.body = {
              :session  => auth_token,
              :memberId => member_id
            }
          end
        rescue Savon::SOAP::Fault => e
          if e.to_hash[:fault][:detail][:fault][:code] == '100'
            # "100" means member ID didn't exist so just return false.
            return false
          else
            # Re-raise cause something else went wrong.
            raise
          end
        end
      end
      true
    end

    # Logon. You don't need to call this explicitly but it's useful for debugging.
    #
    # @return [String] the session id
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

    # Send a parametrized single message to user - you need an existing ecircle template ID for this.
    #
    # @param [Integer] user_id ecircle user_id
    # @param [Integer] message_id the ecircle template ID
    # @param [Array] the names of the variables you want to interpolate in the template
    # @param [Array] the values of the variables you want to interpolate in the template
    # @return nil
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
