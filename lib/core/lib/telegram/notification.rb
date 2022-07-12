module Kogno
module Telegram
class Notification < Kogno::Notification

  def send(recipient_id=nil,delete=true)    
    recipient_id = @recipient.chat_id if recipient_id.nil?
    messages = @before_messages+@messages+@after_messages
    @message_log = messages
    logger.write("\n\nSENDING MESSAGES...\n", :bright) unless messages.empty?
    messages.each do |message|
      case message[:type].to_sym 
        when :action
          sleep(message[:value][:duration]) if message[:value][:action].to_sym == :typing_on
          sent_response = nil
        when :photo
          sent_response = Api::send(recipient_id,message[:value], "sendPhoto")
        when :edit_media
          sent_response = Api::send(recipient_id,message[:value], "editMessageMedia")
        when :edit_text_message
          sent_response = Api::send(recipient_id,message[:value], "editMessageText")
        when :contact
          sent_response = Api::send(recipient_id,message[:value], "sendContact")
        when :location
          sent_response = Api::send(recipient_id,message[:value], "sendLocation")        
        when :message
          sent_response = Api::send(recipient_id,message[:value], "sendMessage")
        else #raw
          sent_response = Api::send(recipient_id,message[:value], message[:type])
      end 
      unless sent_response.nil?        
        if !@recipient.nil? and @recipient.type == :user
          if sent_response[:ok]
            @recipient.save
            match_message_ids(message[:matched_message_id], sent_response[:result][:message_id]) unless message[:matched_message_id].nil?
          end
        end
        @response_log << sent_response     
      end
    end    
    self.delete_messages() if delete
  end

  def match_message_ids(id, message_id)
    return false unless @recipient.type == :user
    matched_message = @recipient.matched_messages.find(id)
    matched_message.platform_message_id = message_id
    matched_message.save
  end

  def match_next_message()
    return false unless @recipient.type == :user
    matched_message = @recipient.matched_messages.create()
    @matched_message_id = matched_message.id
    return @matched_message_id
  end

  def get_matched_message_id(id)
    return false unless @recipient.type == :user
    @recipient.matched_messages.find(id).platform_message_id 
  end

  def answer_inline_query(inline_query_id, delete=true)
    @response_log << Api::answer_inline_query(inline_query_id, @inline_query_results)
    @inline_query_results = [] if delete
  end

  def answer_callback_query(params={},callback_query_id=nil)
    callback_query_id = @message.callback_query_id if callback_query_id.nil?
     Api::answer_callback_query(callback_query_id, params)
  end

  def text(text, extra_params={})
    extra_params[:disable_web_page_preview] = !extra_params[:preview_url] unless extra_params[:preview_url].nil?
    extra_params = {disable_web_page_preview: true}.merge(extra_params)  
    params = {
      text: text
    }.merge(extra_params)
    self.push_message(params, :message)
  end

  def html(code, reply_markup = {} ,extra_params={})
    extra_params[:disable_web_page_preview] = !extra_params[:preview_url] unless extra_params[:preview_url].nil?
    extra_params = {disable_web_page_preview: true}.merge(extra_params)  
    params = {
      text: code,
      parse_mode: "HTML"
    }.merge(self.class.format_to_reply_markup(reply_markup)).merge(extra_params)
    self.push_message(params, :message)
  end

  def markdown(syntax, reply_markup = {} ,extra_params={})
    extra_params[:disable_web_page_preview] = !extra_params[:preview_url] unless extra_params[:preview_url].nil?
    extra_params = {disable_web_page_preview: true}.merge(extra_params)  
    params = {
      text: syntax,
      parse_mode: "MarkdownV2"
    }.merge(self.class.format_to_reply_markup(reply_markup)).merge(extra_params)
    self.push_message(params, :message)
  end

  def typing_on(duration)
    self.push_message({:action => :typing_on, :duration => duration}, :action)
  end

  def inline_keyboard(text,replies, extra_settings={})
    settings = {typed_postbacks: Kogno::Application.config.typed_postbacks, push_message: true}.merge(extra_settings) # defaults
    text = t(text) if text.class == Symbol
    text = Notification::rand_text(text)
    begin
      set_typed_postbacks(replies.map{|reply|
        [reply[:text].to_payload, reply[:callback_data]] unless reply[:text].nil?
      }.compact.to_h) if settings[:typed_postbacks]
    rescue
      nil
    end
    
    replies = replies.each_slice(settings[:slice_replies]).to_a unless settings[:slice_replies].nil?
    result = Api::inline_keyboard_markup(text, replies, settings[:update])
    if settings[:push_message]
      self.push_message(result)
    else
      result
    end
  end

  def keyboard(text,buttons, extra_settings={})
    settings = {typed_postbacks: Kogno::Application.config.typed_postbacks, push_message: true, one_time_keyboard: true}.merge(extra_settings) # defaults
    text = t(text) if text.class == Symbol
    text = Notification::rand_text(text)

    begin
      set_typed_postbacks(buttons.map{|reply|
        [reply[:text].to_payload, reply[:callback_data]] unless reply[:text].nil?
      }.compact.to_h) if settings[:typed_postbacks]
    rescue
      nil
    end

    buttons = buttons.each_slice(settings[:slice_replies]).to_a unless settings[:slice_replies].nil?
    result = Api::keyboard(text, buttons, settings[:one_time_keyboard])
    if settings[:push_message]
      self.push_message(result)
    else
      result
    end
  end

  def button(text,buttons,extra_settings={})
    settings = {push_message: false, one_time_keyboard: true}.merge(extra_settings) # defaults
    buttons = buttons.replace_keys({payload: :callback_data, title: :text})
    self.push_message(self.keyboard(text,buttons,settings))
  end
  
  def quick_reply(text,replies,extra_settings={})
    settings = {typed_postbacks: true, push_message: false, editable: false}.merge(extra_settings) # defaults
    replies = [replies] if replies.class == Hash
    replies = replies.replace_keys({payload: :callback_data, title: :text})


    kgn_id = @message.get_kgn_id rescue nil
    if !kgn_id.nil?
      if kgn_id.class == String
          kogno_message_id = kgn_id.split("-")[1].to_i
          update_message_id = self.get_matched_message_id(kogno_message_id)
      elsif kgn_id.class == Integer
          update_message_id = kgn_id
      end      
    elsif settings[:updateable]
      kgn_id = "kgn-#{self.match_next_message}"
      replies = self.class.add_params_to_reply_payloads(replies, {kgn_id: kgn_id})
    end

    if update_message_id.nil?
      self.push_message(self.inline_keyboard(text,replies,settings))
    else
      replies = self.class.add_params_to_reply_payloads(replies, {kgn_id: update_message_id})
      self.push_message(self.inline_keyboard(text,replies,settings.merge({update: {message_id: update_message_id}})), :edit_text_message)      
    end   

  end

  def location_request(text, button_text="📍")
    self.push_message(Api::keyboard(text, [{text: button_text, request_location: true}]))
  end

  def contact_request(text, button_text="📝")
    self.push_message(Api::keyboard(text, [{text: button_text, request_contact: true}]))
  end

  def contact(params)
    self.push_message(params, :contact)        
  end

  def location(params)
    self.push_message(params, :location)        
  end

  def image(params)

    message = {
      photo: params[:url],
      caption: params[:caption]
    }
    unless params[:buttons].nil?
      replies = params[:buttons].replace_keys({payload: :callback_data, title: :text})
      replies = self.class.array_of_arrays(replies)
      message = message.merge(Api::add_inline_keyboard_markup(replies))
    end
    self.push_message(message, :photo)

  end


  def video(params)
  
    message = {
      video: params[:url],
      caption: params[:caption]
    }
    unless params[:buttons].nil?
      replies = params[:buttons].replace_keys({payload: :callback_data, title: :text})
      replies = self.class.array_of_arrays(replies)
      message = message.merge(Api::add_inline_keyboard_markup(replies))
    end
    self.push_message(message, "sendVideo")

  end

  def url(params)

    inline_keyboard = !params[:button].nil? ? [
      [
        {
          text: params[:button],
          url: params[:url]
        }            
      ]
    ] : []

    message = {
      caption: "<strong><a href=\"#{params[:url]}\">#{params[:title]}</a></strong>\n#{params[:sub_title]}",
      parse_mode: "HTML",
      photo: params[:image],
      reply_markup:{
        inline_keyboard: inline_keyboard
      }           
    }
    
    self.push_message(message,:photo)

  end

  # def carousel(args)

  #   if args[:update_message_id].nil?
  #     update_message_id = "kgn-#{self.match_next_message}"
  #   elsif args[:update_message_id].class == String
  #     kogno_message_id = args[:update_message_id].split("-")[1].to_i
  #     update_message_id = self.get_matched_message_id(kogno_message_id)
  #   else
  #     update_message_id = args[:update_message_id]
  #   end
    
  #   pagination_buttons = []

  #   pagination_back = self.class.convert_keys_to_telegram(args[:pagination][:back])
  #   pagination_next = self.class.convert_keys_to_telegram(args[:pagination][:next])

  #   pagination_back[:callback_data] = self.class.add_params_to_payload(pagination_back[:callback_data], {kgn_id: update_message_id, page: args[:pagination][:current] - 1})
  #   pagination_next[:callback_data]  = self.class.add_params_to_payload(pagination_next[:callback_data], {kgn_id: update_message_id, page: args[:pagination][:current] + 1})

  #   pagination_buttons <<  {text: "«"}.merge(pagination_back) if args[:pagination][:current] > 0
  #   pagination_buttons <<  {text: "»"}.merge(pagination_next) if args[:pagination][:current] < (args[:pagination][:total]-1)
    
  #   reply_markup = self.class.format_to_reply_markup({quick_reply: args[:buttons]})    
  #   logger.debug "reply_markup", :pink
  #   logger.debug_json reply_markup, :pink
  #   logger.debug "pagination_buttons", :pink
  #   reply_markup[:reply_markup][:inline_keyboard] << pagination_buttons
  #   logger.debug_json reply_markup, :pink
  #   if args[:update_message_id].nil?
  #     params = {
  #       caption: "<pre><strong>#{args[:title]}</strong></pre>\n<i>#{args[:description]}</i>",
  #       parse_mode: "HTML",
  #       photo: args[:image]       
  #     }.merge(reply_markup)
  #     self.push_message(params,:photo)
  #   else 
  #     params = {
  #       message_id: update_message_id,
  #       media: {
  #         type: :photo,
  #         caption: "<pre><strong>#{args[:title]}</strong></pre>\n<i>#{args[:description]}</i>",
  #         parse_mode: "HTML",
  #         media: args[:image]
  #       }        
  #     }.merge(reply_markup)
  #     self.push_message(params, :edit_media)        
  #   end
  # end  

  # def url_carousel(args)

  #   if args[:update_message_id].nil?
  #     update_message_id = "kgn-#{self.match_next_message}"
  #   elsif args[:update_message_id].class == String
  #     kogno_message_id = args[:update_message_id].split("-")[1].to_i
  #     update_message_id = self.get_matched_message_id(kogno_message_id)
  #   else
  #     update_message_id = args[:update_message_id]
  #   end
    
  #   pagination_buttons = []

  #   pagination_back = self.class.convert_keys_to_telegram(args[:pagination][:back])
  #   pagination_next = self.class.convert_keys_to_telegram(args[:pagination][:next])

  #   pagination_back[:callback_data] = self.class.add_params_to_payload(pagination_back[:callback_data], {kgn_id: update_message_id, page: args[:pagination][:current] - 1})
  #   pagination_next[:callback_data]  = self.class.add_params_to_payload(pagination_next[:callback_data], {kgn_id: update_message_id, page: args[:pagination][:current] + 1})

  #   pagination_buttons <<  {text: "«"}.merge(pagination_back) if args[:pagination][:current] > 0
  #   pagination_buttons <<  {text: "»"}.merge(pagination_next) if args[:pagination][:current] < (args[:pagination][:total]-1)
    
  #   if args[:update_message_id].nil?
  #     self.push_message(
  #       {

  #         caption: "<strong><a href=\"#{args[:url]}\">#{args[:title]}</a></strong>\n<i>#{args[:description]}</i>",
  #         parse_mode: "HTML",
  #         photo: args[:image],
  #         reply_markup:{
  #           inline_keyboard: [
  #             [
  #               {
  #                 text: args[:button_label],
  #                 url: args[:url]
  #               }            
  #             ],
  #             pagination_buttons
  #           ]
  #         }           
  #       },
  #       :photo
  #     )
  #   else
  #     self.push_message(
        
  #       {
  #         message_id: update_message_id,
  #         media: {
  #           type: :photo,
  #           caption: "<strong><a href=\"#{args[:url]}\">#{args[:title]}</a></strong>\n<i>#{args[:description]}</i>",
  #           parse_mode: "HTML",
  #           media: args[:image]
  #         },
  #         reply_markup:{
  #           inline_keyboard: [
  #             [
  #               {
  #                 text: args[:button_label],
  #                 url: args[:url]
  #               }            
  #             ],
  #             pagination_buttons
  #           ]
  #         }           
  #       },
  #       :edit_media
  #     )        
  #   end
  # end  

  def inline_query_result(type, results)
    body = self.push_inline_query_result(
      {
        type: type,
        id: @inline_query_results.count+1
      }.merge(results)
    )
    body
  end

  protected

  def push_message(message,type=:message) # :message o :action
    new_message = {:type => type, :value => message}
    unless @matched_message_id.nil?
      new_message[:matched_message_id] = @matched_message_id
      @matched_message_id = nil
    end
    logger.debug_json new_message, :blue
    new_message[:value][:reply_markup][:inline_keyboard] = self.class.replace_long_callback_data(new_message[:value][:reply_markup][:inline_keyboard]) if (!new_message[:value][:reply_markup][:inline_keyboard].nil? rescue false)
    new_message[:value][:reply_markup][:keyboard] = self.class.replace_long_callback_data(new_message[:value][:reply_markup][:keyboard]) if (!new_message[:value][:reply_markup][:keyboard].nil? rescue false)
    @messages << new_message
  end

  def push_inline_query_result(result)
    logger.write_json result, :blue 
    @inline_query_results << result
  end

  def self.format_to_reply_markup(args)
    args = {typed_postbacks: Kogno::Application.config.typed_postbacks}.merge(args)
    if !args[:quick_reply].nil?
      inline_keyboard = args[:quick_reply]
      inline_keyboard = convert_keys_to_telegram(inline_keyboard)
      begin
        set_typed_postbacks(inline_keyboard.map{|reply|
          [reply[:text].to_payload, reply[:callback_data]] unless reply[:text].nil?
        }.compact.to_h) if args[:typed_postbacks]
      rescue
        nil
      end
      inline_keyboard = inline_keyboard.each_slice(args[:slice_replies]).to_a unless args[:slice_replies].nil?
      inline_keyboard = array_of_arrays(inline_keyboard)      
      {
        reply_markup: { 
          inline_keyboard: inline_keyboard
        }        
      }
    elsif !args[:button].nil?
      keyboard = args[:button]
      keyboard = convert_keys_to_telegram(keyboard)
      begin
        set_typed_postbacks(keyboard.map{|reply|
          [reply[:text].to_payload, reply[:callback_data]] unless reply[:text].nil?
        }.compact.to_h) if args[:typed_postbacks]
      rescue
        nil
      end
      keyboard = keyboard.each_slice(args[:slice_replies]).to_a unless args[:slice_replies].nil?
      keyboard = array_of_arrays(keyboard)
      
      {
        reply_markup: { 
          keyboard: keyboard,
          one_time_keyboard: true
        }        
      }
    elsif !args.nil?      
      {
        reply_markup: args
      }
    else
      {}
    end

  end

  def self.array_of_arrays(data)
    array = data.class == Array ? data : [data]
    array = [array] unless array.map{|v| v.class}.uniq[0] == Array
    array
  end

  def self.convert_keys_to_telegram(hash)
    hash.replace_keys({payload: :callback_data, label: :text, title: :text})
  end

  def self.add_params_to_payload(callback_data, params_to_add)
    payload = callback_data.split(":",2)[0] rescue nil
    raw_params = callback_data.to_s.split(":",2)[1].to_s
    unless raw_params.empty?
      params = JSON.parse(raw_params, {:symbolize_names => true})
      set_payload(payload, params.merge(params_to_add))
    else
      set_payload(payload, params_to_add) 
    end
  end

  def self.add_params_to_reply_payloads(replies, params_to_add)
    new_replies = []
    replies.each do |reply|
      if reply.class == Array
        new_replies << add_params_to_reply_payloads(reply, params_to_add)
      elsif reply.class == Hash
        new_reply = reply
        new_reply[:callback_data] = add_params_to_payload(new_reply[:callback_data], params_to_add)
        new_replies << new_reply
      else
        new_replies << reply
      end
    end
    return new_replies
  end

  def self.replace_long_callback_data(messages)
    new_messages = []
    messages.each do |message|
      if message.class == Array
        new_messages << replace_long_callback_data(message)
      elsif message.class == Hash
        new_message = message
        unless message[:callback_data].nil?
          new_message[:callback_data] = message[:callback_data].length > 64 ? "kogno__#{LongPayload.set(message[:callback_data])}" : message[:callback_data]
        end
        new_messages << new_message
      else
        new_messages << message
      end
    end
    return new_messages
  end

end
end
end
