module Pheme
  class MessageHandler
    attr_reader :message, :metadata, :timestamp

    def initialize(message:, metadata: {})
      @message = message
      @metadata = metadata
    end

    def handle
      raise NotImplementedError
    end
  end
end
