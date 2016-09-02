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
      Pheme.log(:info, "Publishing to #{topic_arn}: #{message}")
      Pheme.configuration.sns_client.publish(topic_arn: topic_arn, message: message.to_json)
    end
  end
end
