module Kogno
module Telegram
class InlineQuery  < Kogno::Message

  attr_accessor :event

  @overwritten_payload = nil

  def initialize(data)
    @data = data
  end

  def type
    :inline_query
  end

  def platform
    :telegram
  end

  def page_id
    nil
  end

  def chat_type
    @data[:chat_type]
  end

  def id
    return @data[:id]
  end

  def sender_id
    return @data[:from][:id]
  end

  def sender_first_name
    return @data[:from][:first_name] rescue ""
  end

  def sender_last_name
    return @data[:from][:last_name] rescue "" 
  end

  def payload_action
    nil
  end

  def empty?
    self.text.to_s.empty?
  end


  def text
    return (@data[:query].to_s rescue "")
  end

  def get_context(user,notification)
    # Here you can use different contexts by self.post_id
    context_class = Context::router(Kogno::Application.config.routes.inline_query)[:class]
    context = context_class.new(user,self,notification,nil, nil, user)
    return(context)
  end

  def handle_event(debug=false)

    begin

      user = User.find_or_create_by_psid(self.sender_id, :telegram)
      user.first_name = self.sender_first_name
      user.last_name = self.sender_last_name
      user.save

      self.set_nlp(user.locale)
      I18n.locale = user.locale unless user.locale.nil?

      notification = Notification.new(user,self)

      logger.write "--------------------MESSAGE: #{self.text}--------------------------", :green

      context = get_context(user,notification)

      return({post_comment: self, user: user, notification: notification, context: context}) if debug

      context.run_for_text_only

      notification.answer_inline_query(self.id, self.sender_id)

      recipient_psid = notification.get_psid_from_response_log

      user = User.find_or_create_by_psid(self.sender_id, :telegram)

      if Kogno::Application.config.store_log_in_database
        user.log_message(self, :inline_query_received) 
        user.log_response(notification)
      end

      logger.write "**********************#{user.context}***********************", :green
     
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
