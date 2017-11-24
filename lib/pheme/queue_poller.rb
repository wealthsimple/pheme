module Pheme
  class QueuePoller
    attr_accessor :queue_url, :queue_poller, :connection_pool_block, :format, :max_messages, :poller_configuration

    def initialize(queue_url:, connection_pool_block: false, max_messages: nil, format: :json, poller_configuration: {})
      raise ArgumentError, "must specify non-nil queue_url" unless queue_url.present?
      @queue_url = queue_url
      @queue_poller = Aws::SQS::QueuePoller.new(queue_url)
      @connection_pool_block = connection_pool_block
      @format = format
      @max_messages = max_messages
      @poller_configuration = {
        wait_time_seconds: 10, # amount of time a long polling receive call can wait for a mesage before receiving a empty response (which will trigger another polling request)
        idle_timeout: 20, # disconnects poller after 20 seconds of idle time
        skip_delete: true, # manually delete messages
      }.merge(poller_configuration || {})

      if max_messages
        queue_poller.before_request do |stats|
          throw :stop_polling if stats.received_message_count >= max_messages
        end
      end
    end

    def poll
      time_start = log_polling_start
      messages_processed = 0
      messages_received = 0
      with_optional_connection_pool_block do
        queue_poller.poll(poller_configuration) do |queue_message|
          notification = extract_notification(queue_message)
          Pheme.logger.tagged(notification['MessageId']) do
            begin
              messages_received += 1
              log_notification(notification)
              handle(notification[:message])
              queue_poller.delete_message(queue_message)
              log_delete(notification)
              messages_processed += 1
            rescue SignalException
              throw :stop_polling
            rescue StandardError => e
              Pheme.logger.error(e)
              Pheme.rollbar(e, "#{self.class} failed to process message", notification)
            end
          end
        end
      end
      log_polling_end(time_start, messages_received, messages_processed)
    end

    def extract_notification(queue_message)
      notification = JSON.parse(queue_message.body)
      case format
      when :csv
        notification[:message] = parse_csv(notification['Message'])
      when :json
        notification[:message] = parse_json(notification['Message'])
      else
        raise ArgumentError, "Invalid format #{format}. Valid formats: :csv, :json"
      end
      notification
    end

    def parse_csv(message_contents)
      parsed_body = SmarterCSV.process(StringIO.new(message_contents))
      parsed_body.map{ |item| RecursiveOpenStruct.new(item, recurse_over_arrays: true) }
    end

    def parse_json(message_contents)
      parsed_body = JSON.parse(message_contents)
      RecursiveOpenStruct.new({ wrapper: parsed_body }, recurse_over_arrays: true).wrapper
    end

    def handle(_message)
      raise NotImplementedError
    end

    private

    def with_optional_connection_pool_block
      if connection_pool_block
        ActiveRecord::Base.connection_pool.with_connection { yield }
      else
        yield
      end
    end

    def log_polling_start
      time_start = Time.now
      Pheme.logger.info({
        message: "Start long-polling #{queue_url}",
        queue_url: queue_url,
        format: format,
        max_messages: max_messages,
        connection_pool_block: connection_pool_block,
        poller_configuration: poller_configuration,
      }.to_json)
      time_start
    end

    def log_polling_end(time_start, messages_received, messages_processed)
      time_end = Time.now
      elapsed = time_end - time_start
      Pheme.logger.info({
        message: "Finished long-polling #{queue_url}, duration: #{elapsed.round(2)} seconds.",
        queue_url: queue_url,
        format: format,
        messages_received: messages_received,
        messages_processed: messages_processed,
        duration: elapsed.round(2),
        start_time: time_start.utc.iso8601,
        end_time: time_end.utc.iso8601,
      }.to_json)
    end

    def log_delete(notification)
      Pheme.logger.info({
        message: "Deleted #{notification['Type']} - #{notification['MessageId']}",
        notification: notification.slice('Type', 'MessageId'),
      }.to_json)
    end

    def log_notification(notification)
      # we do this so that CSV doesn't get parsed into objects when logging which make it huge and not-copyable
      payload = notification.except(:message)
      payload['Message'] = notification[:message] if format == :json

      Pheme.logger.info({
        message: "Received #{notification['Type']} - #{notification['MessageId']}",
        notification: payload,
      }.to_json)
    end
  end
end
