module Pheme
  def self.rollbar(exception, message, data={})
    return  if configuration.rollbar.nil?

    configuration.rollbar.error(exception, message, data)
  end
end
