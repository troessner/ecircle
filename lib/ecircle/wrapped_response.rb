module Ecircle
  class WrappedResponse
    attr_accessor :success, :message

    def initialize options
      @success = options[:success]
      @message = options[:message]
    end
  end
end
