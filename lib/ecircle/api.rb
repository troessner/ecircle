module Ecircle
  class Api
    #@private
    attr_accessor :auth_token
    @@help = <<-doc
    !!!
    Got an authentication exception, chances are good that you're credentials are wrong, so better double check that.
    You can explicitly check for it by calling something like:
    Ecircle.configure do..
    Ecircle.logon
    !!!
    doc


    #@private
    def ensuring_logon &block
      begin
        @auth_token ||= logon
      rescue Savon::SOAP::Fault => e
        # If we are here this probably means that our login credentials are wrong.
        wrapped_response = WrappedResponse.new(e)
        if wrapped_response.permission_problem?
          puts @@help
          raise
        end
      end

      first_try = true
      begin
        block.call
      rescue Savon::SOAP::Fault => e
        # If we are here that probably means that our session token has expired.
        wrapped_response = WrappedResponse.new(e)
        if wrapped_response.permission_problem?
          if first_try
            first_try = false
            @auth_token = logon
            retry
          else
            puts "!!! Could not re-authenticate after session expired: #{wrapped_response.inspect} !!!"
            raise
          end
        else
          raise  # Re-raise cause something else went wrong.
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
    # @return [WrappedResponse]
    def create_member user_id, group_id, invite = false, send_message = false
      ensuring_logon do
        begin
          @response = client.request :createMember do
            soap.body = {
              :session     => auth_token,
              :userId      => user_id,
              :groupId     => group_id,
              :invite      => invite.to_s,
              :sendMessage => send_message.to_s
            }
          end
        rescue Savon::SOAP::Fault => e
          wrapped_response = WrappedResponse.new(e)
          if wrapped_response.no_such_user? || wrapped_response.no_such_group_when_a_user_was_given
            return wrapped_response
          else
            raise # Re-raise cause something else went wrong.
          end
        end
        WrappedResponse.new(:success => true, :ecircle_id => @response.body[:create_member_response][:create_member_return].to_s)
      end
    end

    # Create or update user by email
    # see http://developer.ecircle-ag.com/apiwiki/wiki/SynchronousSoapAPI#section-SynchronousSoapAPI-UserObjectExample
    # for an example of the user xml
    # @param [Hash] user_xml, in it's most simple form a { :email => 'test@test.com' } is sufficient
    # @return [Integer] the user id
    # TODO Error handling is missing.
    def create_or_update_user_by_email user_attributes
      ensuring_logon do
        @response = client.request :createOrUpdateUserByEmail do
          soap.body = {
            :session     => auth_token, # TODO We can't use @auth_token here cause then the session_id is nil. Why?
            :userXml     => Helper.build_user_xml(user_attributes),
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
        begin
          @response = client.request :deleteGroup do
            soap.body = {
              :session  => auth_token,
              :memberId => group_id
            }
          end
        rescue Savon::SOAP::Fault => e
          wrapped_response = WrappedResponse.new(e)
          if wrapped_response.group_does_not_exist?
            return wrapped_response
          else
            raise # Re-raise cause something else went wrong.
          end
        end
      end
      WrappedResponse.new(:success => true)
    end

    # Delete a member.
    #
    # @param [Integer] member_id ecircle member id
    # @return [WrappedResponse]
    def delete_member member_id
      ensuring_logon do
        begin
          @response = client.request :deleteMember do
            soap.body = {
              :session  => auth_token,
              :memberId => member_id
            }
          end
        rescue Savon::SOAP::Fault => e
          wrapped_response = WrappedResponse.new(e)
          if wrapped_response.member_does_not_exist?
            return wrapped_response
          else
            raise # Re-raise cause something else went wrong.
          end
        end
      end
      WrappedResponse.new(:success => true)
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

    # Log out. Uses the last session token.
    #
    # @return nil
    def logout
      client.request :logout do
        soap.body = {
          :session  => auth_token,
        }
      end
    end

    # Send a parametrized single message to user - you need an existing ecircle template ID for this.
    #
    # @param [Integer] user_id ecircle user_id
    # @param [Integer] message_id the ecircle template ID
    # @param [Array] the names of the variables you want to interpolate in the template
    # @param [Array] the values of the variables you want to interpolate in the template
    # @return [WrappedResponse]
    def send_parametrized_single_message_to_user user_id, message_id, names = [], values = []
      ensuring_logon do
        begin
          @response = client.request :sendParametrizedSingleMessageToUser do
            soap.body = {
              :session           => auth_token,
              :singleMessageId   => message_id,
              :userId            => user_id,
              :names             => names,
              :values            => values
            }
          end
        rescue Savon::SOAP::Fault => e
          return WrappedResponse.new(e)
        end
      end
      WrappedResponse.new(:success => true)
    end
  end
end
