#
# Poller that consume internal AWS Events,
# like S3 notifications, CloudWatch events, etc.
#
# This poller's output message will be a list of hashes,
# each containing one event.
#
module Pheme
  module MessageType
    module AwsEvent
      extend ActiveSupport::Concern

      def get_content(body)
        body['Records']
      end

      def format
        :aws_event
      end

      def parse_aws_event(message_contents)
        ResourceStruct::FlexStruct.new({ wrapper: message_contents }).wrapper
      end
    end
  end
end
