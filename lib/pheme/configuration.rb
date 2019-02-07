module Pheme
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end

  class Configuration
    ATTRIBUTES = %i[sns_client sqs_client logger rollbar].freeze
    attr_accessor(*ATTRIBUTES)

    def initialize
      @logger ||= Logger.new(STDOUT) # rubocop:disable Lint/DisjunctiveAssignmentInConstructor
      @logger = ActiveSupport::TaggedLogging.new(@logger) unless @logger.respond_to?(:tagged)
    end

    def validate!
      ATTRIBUTES.each do |attribute|
        raise "Invalid or missing configuration for #{attribute}"  unless send(attribute).present?
      end
      raise "sns_client must be a Aws::SNS::Client"  unless sns_client.is_a?(Aws::SNS::Client)
      raise "sns_client must be a Aws::SQS::Client"  unless sqs_client.is_a?(Aws::SQS::Client)
    end
  end
end
