module Kogno
module Messenger
class Message < Kogno::Message

  def initialize(data)
    @data = data
  end  

  def platform
    :messenger
  end

  def sender_id
    return @data[:sender][:id]
  end

  def page_id
    return @data[:recipient][:id]
  end

  def raw_payload
    payload = @data[:postback][:payload] rescue nil
    payload = (@data[:message][:quick_reply][:payload] rescue nil) if payload.nil?
    payload = @overwritten_payload if payload.nil?
    return(payload)
  end

  def stickers
    @data[:message][:attachments].map{|a| a[:payload][:sticker_id]}.compact rescue []
  end

  def attachments
    attachments = nil
    attachments = @data[:message][:attachments] rescue nil
    attachments
  end

  def referral(field=nil) # Field could be :context or :params)
    referral = (@data[:postback][:referral] rescue nil)
    referral = @data[:referral] if referral.nil?

    if referral.nil? || referral == ""      
      return nil
    # elsif referral[:ref].nil? || referral[:ref] == ""  
    #   return nil
    elsif field.nil?
      return referral
    elsif field == :source
      return referral[:source]
    elsif field == :type
      return referral[:type]
    elsif field == :ref
      return(referral[:ref] == "" ? nil : referral[:ref])
    else
      ref = (referral[:ref].split(Regexp.union(["/","-"]),2) rescue [])
      if field == :context
        return (ref[0] rescue nil)
      elsif field == :params     
        return digest_referral_params(ref[1])
      else
        return nil
      end 
    end

  end

  def digest_referral_params(params)    
    dparams = {}
    return dparams if params.nil?
    dparams = (JSON.parse(params,{:symbolize_names => true}) rescue {})
    if dparams.empty?
      params.to_s.split(";").each do |param|
        item = param.split(":")
        if item.length > 1
          dparams[item[0].to_sym] = item[1]
        else
          break
        end  
      end  
    end
    dparams = params if dparams.empty?
    return dparams
  end

  def raw_message
    m = @data[:message]
    return nil if m.nil?
    if !m[:text].nil?
      return({
        :type => :text,
        :value => m[:text]
      })
    elsif !m[:attachments].nil?
      m[:attachments].each do |attachment|
        case attachment[:type]
          when "location"
            return({
              :type => :location,
              :value => {
                :lat => attachment[:payload][:coordinates][:lat],
                :lon => attachment[:payload][:coordinates][:long]
              }
            })
        end
      end
    end
  end

  def text
    if (self.raw_message[:type] == :text rescue false)
      return self.raw_message[:value].to_s
    else
      return ""
    end
  end 

  def get_context(user,msg,notification)

    if !(context_from_postback = Context.get_from_payload(msg.payload)).nil?
      context_route = context_from_postback
    elsif !(context_in_link = Context.get(self.referral(:ref))).nil?
      context_route = context_in_link[:context]
      @data[:deep_link_param] = context_in_link[:param]
    elsif !(context_from_typed_postback = Context.get_from_typed_postback(msg,user)).nil?    
      context_route = context_from_typed_postback
    else
      context_route = user.context      
    end

    context_class = Context.router(context_route, msg.type)[:class]
    if context_class.nil?
      user.exit_context
      context_class = Context.router(Kogno::Application.config.routes.default)[:class]
    end
    context = context_class.new(user,msg,notification,context_route)
    context
  end


  def handle_event(debug=false)

    begin

      user = User.find_or_create_by_psid(self.sender_id, :messenger, self.page_id)
      user.get_session_vars
      self.set_nlp(user.locale)
      I18n.locale = user.locale unless user.locale.nil?

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
