module Pheme
  class QueuePoller
    attr_accessor :queue_url, :queue_poller, :connection_pool_block, :format, :max_messages, :poller_configuration

    def initialize(queue_url:, connection_pool_block: false, max_messages: nil, format: :json, poller_configuration: {})
      raise ArgumentError, "must specify non-nil queue_url" unless queue_url.present?
      @queue_url = queue_url
      @queue_poller = Aws::SQS::QueuePoller.new(queue_url)
      @connection_pool_block = connection_pool_block
      @messages_processed = 0
      @messages_received = 0
      @format = format
      @max_messages = max_messages
      @poller_configuration = {
        wait_time_seconds: 10, # amount of time a long polling receive call can wait for a message before receiving a empty response (which will trigger another polling request)
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
      with_optional_connection_pool_block do
        queue_poller.poll(poller_configuration) do |queue_message|
          @messages_received += 1
          Pheme.logger.tagged(queue_message.message_id) do
            begin
              content = parse_body(queue_message)
              handle(content)
              queue_poller.delete_message(queue_message)
              log_delete(queue_message)
              @messages_processed += 1
            rescue SignalException
              throw :stop_polling
            rescue StandardError => e
              Pheme.logger.error(e)
              Pheme.rollbar(e, "#{self.class} failed to process message", content)
            end
          end
        end
      end
      log_polling_end(time_start)
    end

    # returns queue_message.body as hash,
    # stores and parses get_content to body[:content]
    def parse_body(queue_message)
      message_body = JSON.parse(queue_message.body)
      raw_content = get_content(message_body)
      body = get_metadata(message_body)

      case format
      when :csv
        parsed_content = parse_csv(raw_content)
        body['Message'] = raw_content
      when :json
        parsed_content = parse_json(raw_content)
        body['Message'] = parsed_content
      else
        method_name = "parse_#{format}".to_sym
        raise ArgumentError, "Unknown format #{format}" unless respond_to?(method_name)
        parsed_content = __send__(method_name, raw_content)
        body['Records'] = parsed_content
      end

      log_message_received(queue_message, body)
      parsed_content
    end

    def get_metadata(message_body)
      message_body.except('Message', 'Records')
    end

    def get_content(body)
      body['Message']
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
        type: self.class.name,
        queue_url: queue_url,
        format: format,
        max_messages: max_messages,
        connection_pool_block: connection_pool_block,
        poller_configuration: poller_configuration,
      }.to_json)
      time_start
    end

    def log_polling_end(time_start)
      time_end = Time.now
      elapsed = time_end - time_start
      Pheme.logger.info({
        message: "Finished long-polling #{queue_url}, duration: #{elapsed.round(2)} seconds.",
        queue_url: queue_url,
        format: format,
        messages_received: @messages_received,
        messages_processed: @messages_processed,
        duration: elapsed.round(2),
        start_time: time_start.utc.iso8601,
        end_time: time_end.utc.iso8601,
      }.to_json)
    end

    def log_delete(queue_message)
      Pheme.logger.info({
        message: "Deleted message #{queue_message.message_id}",
        message_id: queue_message.message_id,
        queue_url: queue_url,
      }.to_json)
    end

    def log_message_received(queue_message, body)
      Pheme.logger.info({
        message: "Received message #{queue_message.message_id}",
        message_id: queue_message.message_id,
        queue_url: queue_url,
        body: body,
      }.to_json)
    end
  end
end
