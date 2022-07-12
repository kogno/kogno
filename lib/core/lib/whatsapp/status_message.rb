module Kogno
module WhatsApp
class StatusMessage  < Kogno::Message

  @overwritten_payload = nil

  def initialize(data, type=nil)
    @data = data
    @type = type
  end

  def type
    @type
  end

  def platform
    :whatsapp
  end

  def status_raw
    @data[:statuses][0]
  end

  def status
    self.status_raw[:status]
  end

  def metadata
    @data[:metadata]
  end

  def sender_id
    return self.status_raw[:recipient_id]
  end


  def handle_event(debug=false)

    begin

      user = User.find_or_create_by_psid(self.sender_id, :whatsapp)
      if self.status == "read"
        user.mark_last_message_as_read
      end
     
    rescue StandardError => e
      error_token = Digest::MD5.hexdigest("#{Time.now}#{rand(1000)}") # This helps to identify the error that arrives to Slack in order to search it in logs/http.log      
      logger.write e.message, :red
      logger.write "Error Token: #{error_token}", :red
      logger.write "Backtrace:\n\t#{e.backtrace.join("\n\t")}", :red
      ErrorHandler.notify_by_slack(Kogno::Application.config.app_name,e, error_token) if Kogno::Application.config.error_notifier.slack[:enable] rescue false
    end

  end

end
end
end
