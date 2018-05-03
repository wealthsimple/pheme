require_relative 'compression'

module Pheme
  class TopicPublisher
    include Compression

    #
    # Constant with message size limit.
    # The message size also includes some metadata: 'name' and 'type'.
    # We give ourselves a buffer for this metadata.
    #
    # Source: https://docs.aws.amazon.com/sns/latest/dg/SNSMessageAttributes.html#SNSMessageAttributesNTV
    #
    SNS_SIZE_LIMIT = 256.kilobytes
    EXPECTED_METADATA_SIZE = 1.kilobyte
    MESSAGE_SIZE_LIMIT = SNS_SIZE_LIMIT - EXPECTED_METADATA_SIZE

    attr_accessor :topic_arn

    def initialize(topic_arn:)
      raise ArgumentError, "must specify non-nil topic_arn" unless topic_arn.present?
      @topic_arn = topic_arn
    end

    def publish_events
      raise NotImplementedError
    end

    def publish(message)
      payload = {
        message: "#{self.class} publishing message to #{topic_arn}",
        body: message,
        publisher: self.class.to_s,
        topic_arn: topic_arn,
      }
      Pheme.logger.info(payload.to_json)
      Pheme.configuration.sns_client.publish(topic_arn: topic_arn, message: serialize(message))
    end

    def serialize(message)
      message = message.to_json unless message.is_a? String

      return compress(message) if message.bytesize > MESSAGE_SIZE_LIMIT

      message
    end
  end
end
