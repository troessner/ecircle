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

    # According to http://developer.ecircle-ag.com/apiwiki/wiki/SynchronousSoapAPI#section-SynchronousSoapAPI-SampleProtocolExcerpt,
    # a session expires after 10 minutes (600 seconds) of idleness.
    # Our experiments showed that a session can expire even after around 2 minutes,
    # so we'll just get a new session every 1 minute.
    AUTH_TOKEN_TIMEOUT = 60

    # @private
    def client
      @client ||= Savon::Client.new do
        wsdl.document  = Ecircle.configuration.wsdl
        wsdl.endpoint  = Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    # Creates a member, which basically is just an association between a user and a group.
    #
    # @param [Integer] user_id ecircle user_id
    # @param [Integer] group_id ecircle group_id
    # @param [Boolean] invite send an additional invite mail
    # @param [Boolean] send_message send a message by ecircle
    # @return [WrappedResponse]
    def create_member user_id, group_id, invite = false, send_message = false
      body = {
        :userId      => user_id,
        :groupId     => group_id,
        :invite      => invite.to_s,
        :sendMessage => send_message.to_s
      }

      request(:createMember, body) do |response|
        { :ecircle_id => response.body[:create_member_response][:create_member_return].to_s }
      end
    end

    # Create or update group
    # see http://developer.ecircle-ag.com/apiwiki/wiki/SynchronousSoapAPI#section-SynchronousSoapAPI-GroupObjectExample
    # for an example of the group xml
    # @param [Hash] group_xml, in it's most simple form a { :name => 'your name', :description => 'desc', ':email => 'test@test.com' } is sufficient
    # @return [WrappedResponse]
    # Important note: `email` must be unique across all groups AND must be a subdomain of the system you registered at ecircle.
    def create_or_update_group group_attributes
      body = {
        :groupXml => Helper.build_group_xml(group_attributes)
      }

      request(:createOrUpdateGroup, body) do |response|
        { :ecircle_id => response[:create_or_update_group_response][:create_or_update_group_return].to_i }
      end
    end

    # Create or update user by email
    # see http://developer.ecircle-ag.com/apiwiki/wiki/SynchronousSoapAPI#section-SynchronousSoapAPI-UserObjectExample
    # for an example of the user xml
    # @param [Hash] user_xml, in it's most simple form a { :email => 'test@test.com' } is sufficient
    # @return [Integer] the user id
    def create_or_update_user_by_email user_attributes
      body = {
        :userXml     => Helper.build_user_xml(user_attributes),
        :sendMessage => 0
      }

      request(:createOrUpdateUserByEmail, body) do |response|
        { :ecircle_id => response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_i }
      end
    end

    # Delete a member.
    #
    # @param [Integer] group_id ecircle group id
    # @return [WrappedResponse]
    def delete_group group_id
      request(:deleteGroup, :memberId => group_id)
    end

    # Delete a member.
    #
    # @param [Integer] member_id ecircle member id
    # @return [WrappedResponse]
    def delete_member member_id
      request(:deleteMember, :memberId => member_id)
    end

    # Send a parametrized single message to user - you need an existing ecircle template ID for this.
    #
    # @param [Integer] user_id ecircle user_id
    # @param [Integer] message_id the ecircle template ID
    # @param [Array] the names of the variables you want to interpolate in the template
    # @param [Array] the values of the variables you want to interpolate in the template
    # @return [WrappedResponse]
    def send_parametrized_single_message_to_user user_id, message_id, names = [], values = []
      body = {
        :singleMessageId => message_id,
        :userId          => user_id,
        :names           => names,
        :values          => values
      }

      request(:sendParametrizedSingleMessageToUser, body)
    end

    # Logon. You don't need to call this explicitly but it's useful for debugging.
    #
    # @return [String] the session id
    def logon
      response = client.request :logon do
        soap.body = {
          :user   => Ecircle.configuration.user,
          :realm  => Ecircle.configuration.sync_realm,
          :passwd => Ecircle.configuration.password
        }
      end
      response.body[:logon_response][:logon_return].to_s
    rescue Savon::SOAP::Fault => e
      wrapped_response = WrappedResponse.new(e)
      if wrapped_response.not_authenticated? || wrapped_response.permission_problem?
        puts @@help
        raise InvalidLoginCredentials
      else
        raise
      end
    end

    # Log out. Uses the last session token.
    #
    # @return nil
    def logout
      client.request :logout do
        soap.body = {
          :session => auth_token,
        }
      end
      WrappedResponse.new(:success => true)
    end

    def obtain_auth_token
      @auth_token = logon unless auth_token_valid?
      @auth_token_last_used_at = Time.now
      @auth_token
    end

    def auth_token_valid?
      @auth_token_last_used_at && Time.now - @auth_token_last_used_at < AUTH_TOKEN_TIMEOUT
    end

    private

    def request function_name, body
      body[:session] = obtain_auth_token
      begin
        response = client.request(function_name) { soap.body = body }
        response_hash = block_given? ? yield(response) : {}
        response_hash[:success] = true
        WrappedResponse.new(response_hash)
      rescue Savon::SOAP::Fault => e
        WrappedResponse.new(e)
      end
    end
  end
end
