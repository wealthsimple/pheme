class ExampleMessageHandler < Pheme::MessageHandler
  def handle
    case message.status
    when "complete"
      Pheme.log(:info, "Done")
    when "rejected"
      Pheme.log(:error, "Oops")
    end
  end
end
