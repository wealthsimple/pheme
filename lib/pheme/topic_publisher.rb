module Pheme
  class TopicPublisher
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
      return message if message.is_a? String
      message.to_json
    end
  end
end
