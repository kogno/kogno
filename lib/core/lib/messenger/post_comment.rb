module Kogno
module Messenger
class PostComment

  attr_accessor :event

  @overwritten_payload = nil

  def initialize(data, page_id)
    @data = data
    @page_id = page_id
  end

  def type
    :post_comment
  end

  def payload_action
    nil
  end

  def sender_id
    return(@data[:value][:from][:id] rescue nil)
  end

  def sender_name
    return(@data[:value][:from][:name] rescue nil)
  end

  def post_id
    return(@data[:value][:post_id] rescue nil)
  end

  def page_id
    @page_id
  end

  def item_type
    return(@data[:value][:item].to_sym rescue nil)
  end

  def text
    return(@data[:value][:message] rescue "")
  end
 
  def comment_id
    return(@data[:value][:comment_id] rescue nil)
  end

  def get_context(user,notification)
    # Here you can use different contexts by self.post_id
    context_class = Context::router(Kogno::Application.config.routes.post_comment)[:class]
    context_route = nil
    context = context_class.new(user,self,notification,context_route)
    return(context)
  end

  def empty?
    self.text.to_s.empty?
  end

  def handle_event(debug=false)

    begin

      user = User.new(last_usage_at: Time.now, vars:{})
      self.set_nlp(user.locale)

      notification = Notification.new(user,self)

      logger.write "--------------------MESSAGE: #{self.text}--------------------------", :green

      context = get_context(user,notification)

      return({post_comment: self, user: user, notification: notification, context: context}) if debug

      context.run_for_text_only

      notification.send_private_reply(self.comment_id)

      recipient_psid = notification.get_psid_from_response_log

      user = User.find_or_create_by_psid(recipient_psid, :messenger, self.page_id, self.sender_id, false)

      if Kogno::Application.config.store_log_in_database
        user.log_message(self, :post_comment_received) 
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
