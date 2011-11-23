module Ecircle
  class WrappedResponse
    #@private
    attr_accessor :success, :error_message, :fault_code, :ecircle_id

    # We create a wrapped response in 2 cases:
    #   1.) We get a Savon::SOAP::Fault exception, so something went wrong. In this we get passed an exception.
    #   2.) We get back a "regular" response. In this we get passed an hash.
    def initialize options_or_exception
      if options_or_exception.kind_of? Exception
        attributes = options_or_exception.to_hash
        @success       = false
        @error_message = attributes[:fault][:detail][:fault][:error_message]
        @fault_code    = attributes[:fault][:detail][:fault][:code].to_i
      elsif options_or_exception.kind_of? Hash
        @success       = options_or_exception[:success]
        @error_message = options_or_exception[:error_message]
        @fault_code    = options_or_exception[:fault_code] ? options_or_exception[:fault_code].to_i : nil
        @ecircle_id    = options_or_exception[:ecircle_id]
      else
        raise ArgumentError, "!!! Was either expecting a hash or an exception but got: #{options_or_exception.class} !!!"
      end
    end

    # Useful for `delete_member` requests.
    # @return [Boolean]
    def member_does_not_exist?
      @fault_code == 100 && @error_message == 'No Member Id'
    end

    # This method will tell you if referred to a user id that doesn't exist for ecircle.
    # Usefull for create_member requests
    def no_such_user?
      @fault_code == 103 && @error_message == 'No such User'
    end

    # If you do a create_member request where the group id you pass in doesn't exist you get back a "permission problem".
    # Yes, I know. It hurts.
    # @return [Boolean]
    def permission_problem?
      @fault_code == 502 && @error_message = 'Permission Problem'
    end
    alias :no_such_group? :permission_problem?

    def not_authenticated?
      @fault_code == 501 && @error_message == 'Not authenticated'
    end

    # This method will tell you if you referred to a message id that ecircle doesn't know about.
    # Usefull for send_parametrized_message_to_user requests.
    # @return[Boolean]
    def message_id_does_not_exist?
      !!(@error_message =~ /MessageInfo '(\d+)' not found/)
    end

    def success?
      @success
    end
  end
end
