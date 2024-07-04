module Pheme
  def self.capture_exception(exception, message, data = {})
    return if configuration.error_reporting.nil?

    configuration.error_reporting.capture_exception(exception, message, data)
  end
end
