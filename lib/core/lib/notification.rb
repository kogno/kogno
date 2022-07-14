module Kogno
class Notification

  # attr_accessor :template
  # attr_accessor :user, :msg, :context
  # attr_accessor :nlp

  def initialize(recipient=nil,msg=nil)
    @messages = []
    @inline_query_results = []
    @before_messages = []
    @after_messages = []
    @vars = {}
    @recipient = recipient
    @user = @recipient if @recipient.type == :user
    @message = msg
    @response_log = []
    @message_log = []
    @context_obj_for_tilt_template = nil
  end

  def set_context(context)
    @context = context
  end

  def send(messaging_type="RESPONSE",recipient_id=nil,page_id=nil,delete=true)
    logger.write "---- send() not implemented yet for this platform ----", :red  
  end

  def send_using_token()
    logger.write "---- send_with_token() not implemented yet for this platform ----", :red  
  end

  def scheduled(send_at, tag=nil)
    return false unless @recipient.type == :user
    unless @recipient.nil?
      unless @messages.empty?
        @recipient.scheduled_messages.create({
          messages: @messages.to_json,
          tag: tag,
          send_at: send_at
        })
        self.delete_messages()
      else
        logger.write "Error: No messages to send", :red
      end
    end
  end

  def send_private_reply(recipient_id=nil,page_id=nil,delete=true)
    logger.write "---- send_private_reply not implemented yet for this platform ----", :red  
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
    logger.write "---- send_multiple not implemented yet for this platform ----", :red  
  end

  def match_next_message(users,messaging_type)
    logger.write "---- match_next_message isn't working for this platform ----", :red  
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

  def raw(params, type=:message)
    self.push_message(params, type)
  end

  def text(text)
    logger.write "---- text not implemented yet for this platform ----", :red  
  end

  def loading_typing_on(recipient_id)
    logger.write "---- loading_typing_on not implemented yet for this platform ----", :red  
  end

  def loading_typing_off(recipient_id)
    logger.write "---- loading_typing_off not implemented yet for this platform ----", :red  
  end

  def typing_on(duration)
    self.push_message({:action => :typing_on, :duration => duration}, :action)
  end

  def typing(seconds)
    typing_on(seconds.to_i)
  end

  def typing_off
    self.push_message({:action => :typing_off}, :action)
  end

  def quick_reply(text,replies,typed_postbacks=true)
    logger.write "---- quick_reply not implemented yet for this platform ----", :red  
  end

  def button(text,buttons,typed_postbacks=true)
    logger.write "---- button not implemented yet for this platform ----", :red  
  end

  def list(elements,buttons=[])
    logger.write "---- list not implemented yet for this platform ----", :red  
  end

  def messenger_generic_template(elements,image_aspect_ratio=:horizontal, quick_replies=[])
    logger.write "---- messenger_generic_template not implemented yet for this platform ----", :red  
  end

  def whatsapp_template(name, components=[], lang="en_US")
    logger.write "---- whatsapp_template not implemented yet for this platform ----", :red  
  end

  def carousel(elements,last_element={},image_aspect_ratio=:horizontal , quick_replies=[])
    logger.write "---- carousel not implemented yet for this platform ----", :red  
  end

  def recurring_notification_request(args)
    logger.write "---- recurring_notification_request not implemented yet for this platform ----", :red 
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

  def payload(payload,params={})
    "#{payload}:#{params.to_json}"
  end

  def template(route,params={})
    map = digest_template_route(route)
    if map == false
      return false
    else
      action_group = map[:action_group]
      action = map[:action]
    end

    if @context.nil?
      @reply = self
      Context.base_template(action_group,action,params,false, self)
    else
      @context.template(action_group,action,params)
    end
  end

  # def partial(action_group,action,params={})
  #   template(action_group,"#{action}",params)
  # end

  # def template_block(action_group,action,params={},&block)
  #   @reply = self
  #   eval(template(action_group,action,params,true))
  # end

  # def partial_block(action_group,action,params={},&block)
  #   @reply = self
  #   eval(template(action_group,"_#{action}",params,true))
  # end

  def set_typed_postbacks(typed_postbacks)
    return false unless @recipient.type == :user
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
    logger.write "---- location_request not implemented yet for this platform ----", :red  
  end

  def url(params)
    logger.write "---- url not implemented yet for this platform ----", :red  
  end

  def location(params)
    logger.write "---- location not implemented yet for this platform ----", :red  
  end

  def image(params)
    logger.write "---- image not implemented yet for this platform ----", :red  
  end

  def video(params)
    logger.write "---- video not implemented yet for this platform ----", :red  
  end

  def document(params)
    logger.write "---- document not implemented yet for this platform ----", :red  
  end

  def contact(params)
    logger.write "---- contact not implemented yet for this platform ----", :red  
  end    

  def answer_inline_query(inline_query_id, delete=true)
    logger.write "---- answer_inline_query not implemented yet for this platform ----", :red  
  end

  def answer_callback_query(params={},callback_query_id=nil)
    logger.write "---- answer_callback_query not implemented yet for this platform ----", :red  
  end

  def push_inline_query_result(result)
    logger.write "---- push_inline_query_result not implemented yet for this platform ----", :red  
  end

  def html(code, reply_markup = {} ,extra_params={})
    logger.write "---- html not implemented yet for this platform ----", :red  
  end

  def html_template(action_group, action, params, reply_markup = {} ,extra_params={})
    logger.write "---- html_template not implemented yet for this platform ----", :red  
  end

  def render_html_template(action_group, action, params)
    logger.write "---- render_html_template not implemented yet for this platform ----", :red  
  end

  def markdown(params)
    logger.write "---- markdown not implemented yet for this platform ----", :red  
  end

  def confirm(question,params,type=:quick_reply)
    # params example:
    # {
    #   yes: {title: "Yes", payload: true}},
    #   no: {title: "No", :payload: false}
    # }
    if type == :quick_reply
      self.quick_reply(
        question,
        [
          {
            :content_type => :text,
            :title => params[:yes][:title],
            :payload => params[:yes][:payload]
          },
          {
            :content_type => :text,
            :title => params[:no][:title],
            :payload => params[:no][:payload],
          }
        ],
        {typed_postbacks: true}
      )
    elsif type == :button
      self.button(
        question,
        [
          {
            :type => :postback,
            :title => params[:accept_title],
            :payload => params[:accept_payload]
          },
          {
            :type => :postback,
            :title => params[:reject_title],
            :payload => params[:reject_payload]
          }
        ]
      )
    end
    self.set_typed_postbacks({"YES"=>params[:accept_payload], "NO"=> params[:reject_payload], "CANCEL" => params[:reject_payload]})
  end

  protected

  def digest_template_route(route)

    route_array = route.to_s.split("/")
    if route_array.count > 1
      action_group = route_array[0]
      action = route_array[1]
    else
      if !@context.nil?
        action_group = @context.name
        action = route_array[0]
      else
        raise "Can't determine the context for template #{route}"
        return false
      end
    end

    return(
      {
        action_group: action_group,
        action: action
      }
    )

  end

end
end
