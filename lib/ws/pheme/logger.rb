module Ws::Pheme
  def self.log(method, text)
    @logger ||= ActiveSupport::TaggedLogging.new(configuration.logger)
    @tag ||= "ws-pheme_#{SecureRandom.uuid}"
    @logger.tagged(@tag) { @logger.send(method, text) }
  end

  def self.logger
    configuration.logger
  end
end
