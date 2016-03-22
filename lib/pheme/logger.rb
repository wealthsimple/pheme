module Pheme
  def self.log(method, text)
    @logger ||= ActiveSupport::TaggedLogging.new(configuration.logger)
    @tag ||= SecureRandom.uuid
    @logger.tagged(@tag) { @logger.send(method, text) }
  end
end
