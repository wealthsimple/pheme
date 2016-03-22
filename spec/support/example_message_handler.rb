class ExampleMessageHandler < Pheme::MessageHandler
  def handle
    case message.status
    when "complete"
      puts "Done"
    when "rejected"
      puts "Oops"
    end
  end
end
