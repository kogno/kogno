module Kogno
module Messenger
class RecurringNotification < Kogno::Message

  attr_accessor :event
  attr_accessor :nlp

  @overwritten_payload = nil

  def initialize(data)
    @data = data
    @page_id = page_id
  end

  def type
    :recurring_notification
  end

  def sender_id
    return @data[:sender][:id]
  end

  def page_id
    return @data[:recipient][:id]
  end

  def raw_payload
    payload = @data[:optin][:payload] rescue nil
    return(payload)
  end

  def notification_messages_status
    if @data[:optin][:notification_messages_status] == "STOP_NOTIFICATIONS"
      :stopped
    else
      :active
    end
  end

  def get_context(user,notification)
    # Here you can use different contexts by self.post_id
    context_class = Context::router(Kogno::Application.config.routes.recurring_notification)[:class]
    context = context_class.new(user,self,notification,nil)
    return(context)
  end

  def handle_event(debug=false)
  
    begin

      user = User.find_or_create_by_psid(self.sender_id, :messenger, self.page_id)
      user.update_messenger_recurring_notification(@data[:optin])
      user.get_session_vars
      self.set_nlp(user.locale)
      I18n.locale = user.locale unless user.locale.nil?

      notification = Notification.new(user,self)

      context = get_context(user,notification)
      context.run_for_recurring_notification_only

      notification.send

      if Kogno::Application.config.store_log_in_database
        user.log_message(self, :recurring_notifications) 
        user.log_response(notification)
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
