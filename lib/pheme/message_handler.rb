module Pheme
  class MessageHandler
    attr_reader :queue_message, :message, :metadata, :message_attributes, :poller, :timestamp

    def initialize(queue_message:, message:, metadata: {}, message_attributes: {}, poller: nil)
      @queue_message = queue_message
      @message = message
      @metadata = metadata
      @message_attributes = message_attributes
      @poller = poller
    end

    def handle
      raise NotImplementedError
    end

    def increase_message_visibility(duration:)
      poller.sqs_client.change_message_visibility(
        queue_url: poller.queue_url,
        receipt_handle: queue_message.receipt_handle,
        visibility_timeout: duration.to_i,
      )
    end
  end
end
