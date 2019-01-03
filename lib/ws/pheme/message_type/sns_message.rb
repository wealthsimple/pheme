#
# Default poller for messages publish through SNS.
# No need to use this concern unless
# the default behaviour has been overwritten and you
# wish to restore it.
#
module Ws::Pheme
  module MessageType
    module SnsMessage
      extend ActiveSupport::Concern

      def get_content(body)
        body['Message']
      end

      def format
        :json
      end
    end
  end
end
