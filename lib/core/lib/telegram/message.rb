module Kogno
module Telegram
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
    :telegram
  end

  def chat
    if @type == :callback_query
      @data[:message][:chat]
    else
      @data[:chat]
    end
  end

  def chat_id
    self.chat[:id]
  end

  def chat_title
    self.chat[:title]
  end

  def chat_type
    self.chat[:type].to_sym
  end

  def via_bot
    @data[:via_bot] rescue nil
  end

  def inviter_user_id
    @data[:from][:id]
  end

  def page_id
    nil
  end
  
  def attachments
    a = nil
    a = @data[:audio]
    a = @data[:document] if a.nil?
    a = @data[:photo] if a.nil?
    a = @data[:sticker] if a.nil?
    a = @data[:video] if a.nil?
    a = @data[:voice] if a.nil?
    return a
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

  def sender_language
    return @data[:from][:language_code] rescue "" 
  end

  def callback_query_id
    if @type == :callback_query
      return @data[:id]
    else
      return nil
    end
  end

  def raw_payload
    payload = @data[:data] rescue nil
    payload = get_long_payload(payload) unless payload.nil?
    payload = @overwritten_payload if payload.nil?    
    return(payload)
  end

  def get_long_payload(data)
    return @long_payload unless @long_payload.nil?

    long_data = data.split("kogno__",2)
    if long_data.length == 2
      token = long_data[1]
      @long_payload = LongPayload.get(token)
    else
      @long_payload = data
    end

    return @long_payload
  end

  def payload(action_only=false)
    if action_only
      pl = self.raw_payload.split(":",2)[0] rescue nil
      if pl.nil?
        return pl
      else
        return pl.split(Regexp.union(["/","-"])).last
      end
    else
      self.raw_payload.split(":",2)[0] rescue nil
    end
  end

  def referral(field=nil)
    nil
  end

  def payload_action
    payload(true)
  end

  def command(command_only=true)
    bot_command_entity = @data[:entities].find{|e| e[:type] == "bot_command"} rescue nil
    if !bot_command_entity.nil?
      if command_only
        return @data[:text].split(" ").first.sub("/","").split("@")[0]
      else
        return @data[:text]
      end
    else
      return nil
    end
  end

  def deep_link_data
    if self.command == "start"
      command_param = self.command_text.to_s
      if !command_param.empty?
        return command_param
      end
    end
    return nil
  end

  def deep_link_params
  end

  def command_text
    command = self.command(false)
    unless command.nil?
      a = command.split(" ")
      a.shift
      return a.join(" ")
    else
      return ""
    end
  end

  def empty_thread_from_ad?
    if self.empty?
      unless self.referral.nil?
        if self.referral(:source) == "ADS" and self.referral(:type) == "OPEN_THREAD"
          return true
        end
      end
    end    

    return false  
  end

  def params
    raw_params = self.raw_payload.to_s.split(":",2)[1].to_s
    if raw_params.empty?
      return({})
    else  
      p = (JSON.parse(raw_params, {:symbolize_names => true}) rescue nil)
      p = raw_params if p.nil?
      return(p)
    end      
  end

  def get_kgn_id
    self.params[:kgn_id] rescue nil
  end

  def raw_message
    t = @data[:text] rescue nil
    unless t.nil?
      return({
        :type => :text,
        :value => t
      })
    end
  end

  def text
    return self.raw_message[:value].to_s rescue ""
  end

  def overwrite_postback(payload)
    @overwritten_payload = payload
  end

  def location
    if (self.raw_message[:type] == :location rescue false)
      return self.raw_message[:value]
    else
      return nil
    end
  end

  def get_context(user,notification,chat)

    if !(context_from_postback = Context.get_from_payload(self.payload)).nil?
      context_route = context_from_postback
    elsif !(context_in_link = Context.get(self.deep_link_data)).nil?
        context_route = context_in_link[:context]
        @data[:deep_link_param] = context_in_link[:param]
        logger.write "-----context_from_deep_link:#{context_route}-----", :pink
    elsif !(context_from_typed_postback = Context.get_from_typed_postback(self,user)).nil?    
      context_route = context_from_typed_postback
    else
      context_route = user.context      
    end

    context_class = Context.router(context_route)[:class]
    if context_class.nil?
      user.exit_context
      context_class = Context.router(Kogno::Application.config.routes.default)[:class]
    end
    context = context_class.new(user,self,notification,context_route, nil, chat)
    context
  end


  def handle_event(debug=false)

    begin

      unless self.via_bot.nil?
        logger.debug "Shared message via inline_query detected. We don't do nothing here yet.", :pink
        return false
      end

      user = User.find_or_create_by_psid(self.sender_id, :telegram)      
      user.get_session_vars
      user.first_name = self.sender_first_name
      user.last_name = self.sender_last_name
      user.locale = self.sender_language if user.locale.nil?
      user.save

      self.set_nlp(user.locale)
      I18n.locale = user.locale unless user.locale.nil?

      if [:group,:channel, :supergroup].include?(self.chat_type)
        chat = TelegramChatGroup.find_by_chat_id(self.chat_id)
      else
        chat = user
      end


      unless user.vars[:nlp_context_ref].nil?
        self.nlp.set_context_reference(user.vars[:nlp_context_ref])
        user.vars.delete(:nlp_context_ref) # context references will only be used once
      end

      if [:group,:channel, :supergroup].include?(self.chat_type)
        notification = Notification.new(chat,self)
      else 
        notification = Notification.new(user,self)
      end

      self.log_message_info(user)

      context = get_context(user,notification,chat)

      return({msg: self, user: user, notification: notification, context: context, chat: chat}) if debug

      unless empty_thread_from_ad?

        called_action = context.run      
        if Kogno::Application.config.store_log_in_database   
          message_log_id = user.log_message(self).id
        else
          message_chat_log_id = 0
        end     
             
        notification.answer_callback_query if self.type == :callback_query
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
