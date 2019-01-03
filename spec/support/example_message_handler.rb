class ExampleMessageHandler < Ws::Pheme::MessageHandler
  def handle
    case message.status
    when "complete"
      Ws::Pheme.logger.info("Done")
    when "rejected"
      Ws::Pheme.logger.error("Oops")
    end
  end
end
