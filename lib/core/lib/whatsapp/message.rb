module Kogno
module WhatsApp
class Message  < Kogno::Message

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

  def metadata
    @data[:metadata]
  end

  def sender_id
    return @data[:contacts][0][:wa_id]
  end

  def sender_name
    return @data[:contacts][0][:profile][:name] rescue ""
  end

  def attachments
    message = @data[:messages][0]
    a = nil
    a = message[:audio]
    a = message[:document] if a.nil?
    a = message[:image] if a.nil?
    a = message[:video] if a.nil?
    return a
  end


  def raw_message
    t = @data[:messages][0][:text][:body] rescue nil
    unless t.nil?
      return({
        :type => :text,
        :value => t
      })
    end
  end

  def raw_payload
    payload = @data[:messages][0][:button][:payload] rescue nil
    payload = (@data[:messages][0][:interactive][:button_reply][:id] rescue nil) if payload.nil?
    payload = (@data[:messages][0][:interactive][:list_reply][:id] rescue nil) if payload.nil?
    payload = @overwritten_payload if payload.nil?
    return(payload)
  end

  def text
    return self.raw_message[:value].to_s rescue ""
  end


  def handle_event(debug=false)

    begin

      user = User.find_or_create_by_psid(self.sender_id, :whatsapp)
      user.get_session_vars

      self.set_nlp(user.locale)

      I18n.locale = user.locale unless user.locale.nil?

      self.set_nlp(I18n.locale)

      unless user.vars[:nlp_context_ref].nil?
        self.nlp.set_context_reference(user.vars[:nlp_context_ref])
        user.vars.delete(:nlp_context_ref) # context references will only be used once
      end

      notification = Notification.new(user,self)

      self.log_message_info(user)

      context = get_context(user,self,notification)

      return({msg: self, user: user, notification: notification, context: context}) if debug

      unless empty_thread_from_ad?

        called_action = context.run      
        if Kogno::Application.config.store_log_in_database   
          message_log_id = user.log_message(self).id
        else
          message_chat_log_id = 0
        end     
             
        notification.send

        response_log_id = 0
        if Kogno::Application.config.store_log_in_database
          response_log = user.log_response(notification)          
          response_log_id = response_log.id unless response_log.nil?        
        end  

        # user.set_last_usage
        user.save_session_vars
        context.handle_message_from_memory

      else
        context.run_class_callbacks_only
        user.save_session_vars
        user.log_message(self) if Kogno::Application.config.store_log_in_database         
      end
      logger.write "- Current user context: #{user.context}", :blue unless user.context.nil?
     
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
