module Pheme
  class MessageHandler
    attr_reader :message, :metadata, :message_attributes, :timestamp

    def initialize(message:, metadata: {}, message_attributes: {})
      @message = message
      @metadata = metadata
      @message_attributes = message_attributes
    end

    def handle
      raise NotImplementedError
    end
  end
end
