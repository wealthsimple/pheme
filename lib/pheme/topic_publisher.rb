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

    class << self
      attr_reader :_topic_arn

      def topic_arn(topic_arn)
        @_topic_arn = topic_arn
      end
    end

    def initialize(topic_arn: self.class._topic_arn)
      raise ArgumentError, "must specify non-nil topic_arn" if topic_arn.blank?

      @topic_arn = topic_arn
    end
    attr_accessor :topic_arn

    def publish_events
      raise NotImplementedError
    end

    def publish(message,
      sns_client: Pheme.configuration.sns_client,
      message_attributes: nil,
      message_deduplication_id: nil,
      message_group_id: nil)
      payload = {
        message: "#{self.class} publishing message to #{topic_arn}",
        body: message,
        publisher: self.class.to_s,
        topic_arn: topic_arn,
      }

      Pheme.logger.info(payload.except(:body).to_json)

      sns_client.publish(
        topic_arn: topic_arn,
        message: serialize(message),
        message_attributes: message_attributes,
        message_deduplication_id: message_deduplication_id,
        message_group_id: message_group_id,
      )
    end

    def serialize(message)
      message = message.to_json unless message.is_a? String

      return compress(message) if message.bytesize > MESSAGE_SIZE_LIMIT

      message
    end
  end
end
