module Pheme
  def self.capture_exception(exception, message, data = {})
    return if configuration.error_reporting_func.nil?

    configuration.error_reporting_func.call(exception, message, data)
  end
end
