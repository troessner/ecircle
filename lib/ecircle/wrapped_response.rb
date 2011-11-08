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

    def member_does_not_exist?
      @fault_code == 100
    end

    def group_does_not_exist?
      @fault_code == 500
    end

    def no_such_user?
      @fault_code == 500
    end

    def permission_problem?
      @fault_code == 502 && @error_message = 'Permission Problem'
    end

    def no_such_group_when_a_user_was_given?
      # YES, this IS horrible. Thanks ecircle. "Group does not exist" error codes vary depending on context.
      @fault_code == 502 && @error_message = 'Permission Problem'
    end

    def success?
      @success
    end
  end
end
