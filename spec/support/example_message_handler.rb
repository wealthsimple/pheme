class ExampleMessageHandler < Pheme::MessageHandler
  def handle
    case message.status
    when "complete"
      Pheme.logger.info("Done")
    when "rejected"
      Pheme.logger.error("Oops")
    end
  end
end
