require_relative 'compression'

module Pheme
  class QueuePoller
    include Compression

    attr_accessor :queue_url, :queue_poller, :connection_pool_block, :format, :max_messages, :poller_configuration

    def initialize(queue_url:,
                   connection_pool_block: false,
                   max_messages: nil,
                   format: :json,
                   poller_configuration: {},
                   sqs_client: nil,
                   idle_timeout: nil,
                   message_handler: nil,
                   &block_message_handler)
      raise ArgumentError, "must specify non-nil queue_url" if queue_url.blank?

      @queue_url = queue_url
      @queue_poller = Aws::SQS::QueuePoller.new(queue_url, client: sqs_client)
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

      @poller_configuration[:idle_timeout] = idle_timeout unless idle_timeout.nil?

      if message_handler
        if message_handler.ancestors.include?(Pheme::MessageHandler)
          @message_handler = message_handler
        else
          raise ArgumentError, 'Invalid message handler, must inherit from Pheme::MessageHandler'
        end
      end

      @block_message_handler = block_message_handler

      raise ArgumentError, 'only provide a message_handler or a block, not both' if @message_handler && @block_message_handler

      if max_messages
        queue_poller.before_request do |stats|
          throw :stop_polling if stats.received_message_count >= max_messages
        end
      end
    end

    def poll
      time_start = log_polling_start
      queue_poller.poll(poller_configuration) do |queue_message|
        @messages_received += 1
        Pheme.logger.tagged(queue_message.message_id) do
          begin
            content = parse_body(queue_message)
            metadata = parse_metadata(queue_message)
            message_attributes = parse_message_attributes(queue_message)
            with_optional_connection_pool_block { handle(content, metadata, message_attributes) }
            queue_poller.delete_message(queue_message)
            log_delete(queue_message)
            @messages_processed += 1
          rescue SignalException
            throw :stop_polling
          rescue StandardError => e
            Pheme.logger.error(e)
            Pheme.rollbar(e, "#{self.class} failed to process message", { message: content })
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

    def parse_metadata(queue_message)
      message_body = JSON.parse(queue_message.body)
      { timestamp: message_body['Timestamp'], topic_arn: message_body['TopicArn'] }
    end

    def parse_message_attributes(queue_message)
      message_attributes = {}
      queue_message.message_attributes&.each do |key, value|
        message_attributes[key.to_sym] = coerce_message_attribute(value)
      end

      message_attributes
    end

    def get_metadata(message_body)
      message_body.except('Message', 'Records')
    end

    def get_content(body)
      decompress(body['Message'])
    end

    def parse_csv(message_contents)
      parsed_body = SmarterCSV.process(StringIO.new(message_contents))
      parsed_body.map { |item| RecursiveOpenStruct.new(item, recurse_over_arrays: true) }
    end

    def parse_json(message_contents)
      parsed_body = JSON.parse(message_contents)
      RecursiveOpenStruct.new({ wrapper: parsed_body }, recurse_over_arrays: true).wrapper
    end

    def handle(message, metadata, message_attributes)
      if @message_handler
        @message_handler.new(message: message, metadata: metadata, message_attributes: message_attributes).handle
      elsif @block_message_handler
        @block_message_handler.call(message, metadata, message_attributes)
      else
        raise NotImplementedError
      end
    end

    private

    def coerce_message_attribute(value)
      case value['data_type']
      when 'String'
        value['string_value']
      when 'Number'
        JSON.parse(value['string_value'])
      when 'String.Array'
        JSON.parse(value['string_value'])
      when 'Binary'
        value['binary_value']
      else
        Pheme.logger.info("Unsupported custom data type")
        value["string_value"]
      end
    end

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
        message: "#{self.class} start long-polling #{queue_url}",
        queue_url: queue_url,
        queue_poller: self.class.to_s,
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
        message: "#{self.class} finished long-polling #{queue_url}, duration: #{elapsed.round(2)} seconds.",
        queue_url: queue_url,
        format: format,
        queue_poller: self.class.to_s,
        messages_received: @messages_received,
        messages_processed: @messages_processed,
        duration: elapsed.round(2),
        start_time: time_start.utc.iso8601,
        end_time: time_end.utc.iso8601,
      }.to_json)
    end

    def log_delete(queue_message)
      Pheme.logger.debug({
        message: "#{self.class} deleted message #{queue_message.message_id}",
        message_id: queue_message.message_id,
        queue_poller: self.class.to_s,
        queue_url: queue_url,
      }.to_json)
    end

    def log_message_received(queue_message, body)
      Pheme.logger.debug({
        message: "#{self.class} received message #{queue_message.message_id}",
        queue_poller: self.class.to_s,
        message_id: queue_message.message_id,
        queue_url: queue_url,
        body: body,
      }.to_json)
    end
  end
end
