module Pheme
  class MessageHandler
    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def handle
      raise NotImplementedError
    end
  end
end
