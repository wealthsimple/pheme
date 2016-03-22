module Pheme
  class QueuePoller
    attr_accessor :queue_url, :queue_poller, :connection_pool_block, :poller_configuration

    def initialize(queue_url:, connection_pool_block: false, poller_configuration: {})
      @queue_url = queue_url
      @queue_poller = Aws::SQS::QueuePoller.new(queue_url)
      @connection_pool_block = connection_pool_block
      @poller_configuration = poller_configuration.merge({
        wait_time_seconds: 10, # amount of time a long polling receive call can wait for a mesage before receiving a empty response (which will trigger another polling request)
        idle_timeout: 20, # disconnects poller after 20 seconds of idle time
        visibility_timeout: 30, # length of time in seconds that this message will not be visible to other receiving components
        skip_delete: true, # manually delete messages
      })
    end

    def poll
      Pheme.log(:info, "Long-polling for messages on #{queue_url}")
      with_optional_connection_pool_block do
        queue_poller.poll(poller_configuration) do |message|
          begin
            handle(parse_message(message))
            queue_poller.delete_message(message)
          rescue => e
            Pheme.log(:error, "Exception: #{e.inspect}")
            Pheme.log(:error, e.backtrace.join("\n"))
          end
        end
      end
      Pheme.log(:info, "Finished long-polling after #{@poller_configuration[:idle_timeout]} seconds.")
    end

    def parse_message(message)
      Pheme.log(:info, "Received JSON payload: #{message.body}")
      body = JSON.parse(message.body)
      parsed_body = JSON.parse(body['Message'])
      RecursiveOpenStruct.new(parsed_body, recurse_over_arrays: true)
    end

    def handle(message)
      raise NotImplementedError
    end

  private

    def with_optional_connection_pool_block(&blk)
      if connection_pool_block
        ActiveRecord::Base.connection_pool.with_connection { blk.call }
      else
        blk.call
      end
    end
  end
end
