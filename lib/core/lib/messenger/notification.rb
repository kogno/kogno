module Kogno
module Messenger
class Notification < Kogno::Notification

  def set_context(context)
    @context = context
  end

  def send(messaging_type="RESPONSE",recipient_id=nil,page_id=nil,delete=true)
    recipient_id = @recipient.psid if recipient_id.nil?
    page_id = @recipient.page_id if page_id.nil?
    messages = @before_messages+@messages+@after_messages
    @message_log = messages
    messages.each do |message|
      if message[:type].to_sym == :action
        @response_log << Api::send_action(recipient_id,message[:value][:action],messaging_type,page_id)
        sleep(message[:value][:duration]) if message[:value][:action].to_sym == :typing_on
      else
        message = self.replace_place_holders(message[:value])
        @response_log << Api::send_message(recipient_id,message,messaging_type,page_id)
      end
    end    
    self.delete_messages() if delete
  end

  def send_using_token()
    notification_token = @recipient.messenger_recurring_notification.token rescue nil
    if notification_token.nil?
      logger.write "Error. The user doesn't have a messenger recurring notification token", :red
      return false
    end
    page_id = @recipient.page_id if page_id.nil?
    messages = @before_messages+@messages+@after_messages
    @message_log = messages
    messages.each do |message|
      if message[:type].to_sym == :action
        # @response_log << Api::send_action(recipient_id,message[:value][:action],messaging_type,page_id)
        sleep(message[:value][:duration]) if message[:value][:action].to_sym == :typing_on
      else
        message = self.replace_place_holders(message[:value])
        @response_log << Api::send_message_with_rn_token(notification_token,message,page_id)
      end
    end    
    self.delete_messages()
  end


  # def schedule(send_at, tag=nil)
  #   unless @recipient.nil?
  #     @recipient.scheduled_messages.create({
  #       messages: @messages.to_json,
  #       tag: tag,
  #       send_at: send_at
  #     })
  #     self.delete_messages()
  #   end
  # end

  def send_private_reply(recipient_id=nil,page_id=nil,delete=true)
    response = []
    recipient_id = @recipient.psid if recipient_id.nil?
    @message_log = @messages
    @messages.each do |message|
      message = self.replace_place_holders(message[:value])
      @response_log << Api::send_private_reply(recipient_id,message,page_id)
    end
    self.delete_messages() if delete
  end

  def response_log
    @response_log
  end

  def message_log
    @message_log
  end

  def destroy_message_log
    @message_log = []
  end

  def get_psid_from_response_log
    return(@response_log.first[:recipient_id] rescue nil)
  end
  
  def send_multiple(users,messaging_type)
    logger.write "Sending..", :green
    logger.write_json @messages, :bright
    logger.write "To:", :green
    users.each do |user|
      logger.write "PSID: #{user[:psid]}", :bright
      send(messaging_type,user[:psid],user[:page_id],false)
    end
    self.delete_messages()
  end

  def import_messages(messages,position="")
    messages = messages.class == Array ? messages : JSON.parse(messages,{:symbolize_names => true})
    case position.to_sym
      when :before
        @before_messages = messages
      when :after
        @after_messages = messages
      else
        @messages = messages
    end
  end

  def export_messages

    messages = @messages.to_json
    self.delete_messages()
    return messages

  end

  def delete_messages()
    @before_messages = []
    @messages = []
    @after_messages = []
  end

  def text(text, extra_params={})
    text = t(text) if text.class == Symbol
    text = Notification::rand_text(text)
    self.push_message(Api::text_message(text))
  end

  def loading_typing_on(recipient_id)
    Api::send_action(recipient_id,:typing_on)
  end

  def loading_typing_off(recipient_id)
    Api::send_action(recipient_id,:typing_off)
  end

  def typing_on(duration)
    self.push_message({:action => :typing_on, :duration => duration}, :action)
  end

  def typing_off
    self.push_message({:action => :typing_off}, :action)
  end

  def quick_reply(text,replies,extra_settings={})
    settings = {typed_postbacks: Kogno::Application.config.typed_postbacks}.merge(extra_settings) # defaults
    replies = [replies] if replies.class == Hash
    replies = replies.map{|h| {content_type: :text}.merge(h)}
    text = t(text) if text.class == Symbol
    text = Notification::rand_text(text)
    replies = replies.map{|r| {title: r[:title], payload: r[:payload], content_type: r[:content_type] || :text}} # :text as default
    set_typed_postbacks(replies.map{|reply|
      [reply[:title].to_payload, reply[:payload]] unless reply[:title].nil?
    }.compact.to_h) if settings[:typed_postbacks]
    self.push_message(Api::quick_replies(text, replies))
  end

  def button(text,buttons,extra_settings={})
    settings = {typed_postbacks: Kogno::Application.config.typed_postbacks}.merge(extra_settings) # defaults
    buttons = buttons.map{|h| {type: :postback}.merge(h)}
    text = t(text) if text.class == Symbol
    text = Notification::rand_text(text)
    set_typed_postbacks(buttons.map{|button|
      [button[:title].to_payload, button[:payload]] if button[:type] == :postback
    }.compact.to_h) if settings[:typed_postbacks]
    self.push_message(Api::button_template(text,buttons))
  end

  def messenger_generic_template(elements,image_aspect_ratio=:horizontal, quick_replies=[])
    if quick_replies.empty?
      message = Api::generic_template(elements,image_aspect_ratio)
    else
      quick_replies = [quick_replies] if quick_replies.class == Hash
      quick_replies = quick_replies.map{|h| {content_type: :text}.merge(h)}
      message = Api::generic_template_with_replies(elements,image_aspect_ratio, quick_replies)
    end
    self.push_message(message)  
  end

  def url(params)
    params[:messenger_extensions] = false if params[:messenger_extensions].nil?
    params[:image_aspect_ratio] = :horizontal if params[:image_aspect_ratio].nil?

    ge_params = {
      title: params[:title],
      image_url: params[:image],
      default_action: {
        type: :web_url,
        url: params[:url],
        messenger_extensions: params[:messenger_extensions]
      }
    }

    ge_params[:buttons] =  [
      {
        type: :web_url,
        url: params[:url],
        title: params[:button],
        messenger_extensions: params[:messenger_extensions]
      }
    ] unless params[:button].nil?

    self.messenger_generic_template(ge_params,params[:image_aspect_ratio])
  end
  

  def carousel(elements, quick_replies=[], image_aspect_ratio=:horizontal)
    elements = elements[0..9]
    elements.map do |element| # sharing element: se va a enviar el mismo elemento con los modificadores agregados en :share_contents
      unless element[:buttons].nil?
        element[:buttons].map do |button|
          if button[:type] == :element_share
            share_element = Marshal.load(Marshal.dump(element))
            share_element[:buttons].delete_if{|button| button[:type] == :element_share }
            button[:share_contents] = Api::generic_template(share_element.merge(button[:share_contents]))
          end
        end
      end
    end

    if quick_replies.empty?
      message = Api::generic_template(elements,image_aspect_ratio)
    else
      message = Api::generic_template_with_replies(elements,image_aspect_ratio, quick_replies)
    end
    self.push_message(message)  
  end

  def recurring_notification_request(request)

    attachment = {
      type: :template,
      payload: {
        template_type: :notification_messages, 
        title: request[:title],
        notification_messages_frequency: request[:frequency].to_s.upcase,
        notification_messages_reoptin: request[:reoptin] ? "ENABLED" : "DISABLED",
      }
    }

    attachment[:payload][:image_url] = request[:image_url] unless request[:image_url].nil?
    attachment[:payload][:payload] = request[:payload] unless request[:payload].nil?
    attachment[:payload][:notification_messages_timezone] = request[:timezone] unless request[:timezone].nil?

    self.push_message(Api.attachment_message(attachment))

  end

  def image(params)
    params[:image_aspect_ratio] = :horizontal if params[:image_aspect_ratio].nil?

    message = {
      title: params[:caption],
      image_url: params[:url]
    }

    quick_replies = []
    quick_replies = params[:buttons] unless params[:buttons].nil?

    self.messenger_generic_template(message,params[:image_aspect_ratio], quick_replies)

  end

  def video(params)

    message = {
      type: :template,
      payload: {
          template_type: :media,
          elements: [
            {
                media_type: :video,
                url: params[:url]
            }
         ]
      }
    } 

    unless params[:buttons].nil?
      buttons = params[:buttons].class == Hash ? [params[:buttons]] : params[:buttons]
      buttons.map{|button| {type: :postback}.merge(button)}
      message[:payload][:elements][0][:buttons] = buttons
    end

    Api::attachment_message(message)
  end  

  def set_vars(vars)
    @vars = @vars.merge(vars)
  end

  def self.rand_text(text)    
    if text.class == Array
      return(text[rand(text.count)])
    else
      return(text)
    end
  end


  def replace_place_holders(message)
    message_in_json = message.to_json
    @vars.each do |place_holder,replacement_value|
     message_in_json = message_in_json.gsub(":::#{place_holder}:::",replacement_value.to_s)
    end
    JSON.parse(message_in_json)
  end


  def push_message(message,type=:message) # :message o :action
    new_message = {:type => type, :value => message}
    logger.debug_json new_message, :blue
    @messages << new_message
  end


  def set_typed_postbacks(typed_postbacks)
    @recipient.vars[:typed_postbacks] = {} if @recipient.vars[:typed_postbacks].nil?
    @recipient.vars[:typed_postbacks] = @recipient.vars[:typed_postbacks].merge(typed_postbacks)
  end

  # Advanced responses.

  # def opt_out(text, button_label)
  #   self.quick_reply(
  #     text,
  #     [
  #       {
  #         :content_type => :text,
  #         :title => button_label,
  #         :payload => PAYLOADS[:opt_out]
  #       }
  #     ]
  #   )
  # end

  def location_request(text) # Deprecated by Facebook
    self.quick_reply(
      text,
      [
        {
          :content_type => :location
        }
      ],
      {typed_postbacks: false}
    )
  end

end
end
end
