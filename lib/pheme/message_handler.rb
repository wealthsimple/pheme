module Pheme
  class MessageHandler
    attr_reader :message, :timestamp

    def initialize(message:, timestamp:)
      @message = message
    end

    def handle
      raise NotImplementedError
    end
  end
end
