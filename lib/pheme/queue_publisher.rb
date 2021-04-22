require_relative 'compression'

module Pheme
  class QueuePublisher
    include Compression

    #
    # Constant with message size limit.
    # The message size also includes some metadata: 'name' and 'type'.
    # We give ourselves a buffer for this metadata.
    #
    # Source: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html
    #
    SQS_SIZE_LIMIT = 256.kilobytes
    EXPECTED_METADATA_SIZE = 1.kilobyte
    MESSAGE_SIZE_LIMIT = SQS_SIZE_LIMIT - EXPECTED_METADATA_SIZE

    class << self
      attr_reader :_queue_url

      def queue_url(queue_url)
        @_queue_url = queue_url
      end
    end

    def initialize(queue_url: self.class._queue_url)
      raise ArgumentError, "must specify non-nil queue_url" if queue_url.blank?

      @queue_url = queue_url
    end
    attr_accessor :queue_url

    def publish_event
      raise NotImplementedError
    end

    def publish_events
      raise NotImplementedError
    end

    def send_message(message, sqs_client: Pheme.configuration.sqs_client, message_attributes: nil)
      payload = {
        message: "#{self.class} publishing message to #{queue_url}",
        body: message,
        publisher: self.class.to_s,
        queue_url: queue_url,
      }
      Pheme.logger.info(payload.to_json)

      sqs_client.send_message(queue_url: queue_url, message_body: serialize(message), message_attributes: message_attributes)
    end

    def send_message_batch(entries, sqs_client: Pheme.configuration.sqs_client)
      payload = {
        message: "#{self.class} publishing message batch to #{queue_url}",
        entries: entries,
        publisher: self.class.to_s,
        queue_url: queue_url,
      }
      Pheme.logger.info(payload.to_json)

      sqs_client.send_message_batch(queue_url: queue_url, entries: entries)
    end

    def serialize(message)
      message = message.to_json unless message.is_a? String

      return compress(message) if message.bytesize > MESSAGE_SIZE_LIMIT

      message
    end
  end
end
