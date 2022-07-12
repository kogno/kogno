module Kogno
class Message

  attr_accessor :event

  @overwritten_payload = nil

  def type
    :message
  end

  def sender_id
    0
  end

  def page_id
    nil
  end

  def stickers
    []
  end

  def attachments
    []
  end

  def referral(field=nil)
    nil
  end

  def deep_link_data
    nil
  end

  def set_nlp(lang)
    @nlp = Nlp.new(self.text,lang)
  end 

  def nlp
    @nlp
  end

  def deep_link_param
    @data[:deep_link_param] rescue nil
  end

  def webhook_data
    @data
  end

  def overwrite_postback(payload)
    @overwritten_payload = payload
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

  def payload_action
    self.payload(true)
  end

  def postback_payload
    self.payload(true)
  end

  def postback_params
    self.params
  end

  # def event
  #   JSON.parse(self.body,{:symbolize_names => true})
  # end

  def empty?
    self.raw_payload.nil? && self.raw_message.nil? && self.attachments.nil?
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

   def raw_payload
    # In order to implement in another platform, this function must exist
    nil
  end

  def raw_message
    # In order to implement in another platform, this function must exist
    {}
  end

  def text
    # In order to implement in another platform, this function must exist
    ""
  end

  def numbers_in_text
    # self.text.scan(/\d+/).map{|n| n.to_i}
    self.text.scan(/(\d+(?:\.\d+)?)/).map{|n| n.first}
  end

  def location
    if (self.raw_message[:type] == :location rescue false)
      return self.raw_message[:value]
    else
      return nil
    end
  end

  def get_context(user,msg,notification)

    # Context::call_typed_postbacks(msg,user) if msg.payload.nil? && !user.vars[:typed_postbacks].nil?
    # user.vars.delete(:typed_postbacks)
    
    if !(context_from_postback = Context.get_from_payload(msg.payload)).nil?
      context_route = context_from_postback
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
    # In order to implement in another platform, this function must exist  
  end

  def log_message_info(user)
    context = user.context
    logger.write "\n-------- INCOMING MESSAGE -------", :yellow
    logger.write "Text    : \"#{self.text}\"", :yellow
    unless self.params.empty?
      logger.write "Payload : #{self.payload} => params: #{self.params}", :yellow
    else
      logger.write "Payload : #{self.payload}", :yellow
    end
    logger.write "User ID : #{user.psid}", :yellow
    logger.write "Context : #{(context.nil? || context.empty?) ? Kogno::Application.config.routes.default : context}", :yellow    
    logger.write "---------------------------------\n", :yellow
  end

end
end
