module Kogno
module WhatsApp
class Notification < Kogno::Notification

  def send(recipient_id=nil,delete=true)    
    recipient_id = @recipient.psid if recipient_id.nil?
    page_id = @recipient.page_id if page_id.nil?
    messages = @before_messages+@messages+@after_messages
    @message_log = messages
    messages.each do |message|
      if message[:type].to_sym == :action
        sleep(message[:value][:duration]) if message[:value][:action].to_sym == :typing_on
      else
        message = self.replace_place_holders(message[:value])
        @response_log << Api::send(recipient_id,message)
      end
    end    
    self.delete_messages() if delete
    @recipient.mark_last_message_as_unread unless @recipient.nil?
  end

  def text(text, extra_params={})
    extra_params = {preview_url: false}.merge(extra_params)  
    params = {
      type: :text,
      text: {
        body: text
      }.merge(extra_params)
    }  
    self.push_message(params, :message)
  end


  def typing_on(duration)
    self.push_message({:action => :typing_on, :duration => duration}, :action)
  end

  def whatsapp_template(name, components=[], lang="en_US")
    self.push_message(Api::template_message(name, components, lang), :message)
  end

  def button(text, replies, extra_settings={})
    replies = [replies] if replies.class == Hash
    settings = {typed_postbacks: Kogno::Application.config.typed_postbacks}.merge(extra_settings) # defaults
    replies = replies.replace_keys({payload: :id})
    buttons = replies.map do |reply|
      {
        type: :reply,
        reply: reply
      }
    end

    set_typed_postbacks(replies.map{|button|
      [button[:title].to_payload, button[:id]] unless button[:title].nil?
    }.compact.to_h) if settings[:typed_postbacks]

    self.push_message(Api::interactive_buttons(text, buttons), :message)
  end

  def quick_reply(text, replies, extra_settings={})
    self.button(text, replies, extra_settings)
  end

  def list(params,header={},footer={})
    params[:sections] = params[:sections].map{|s| 
      {
        title: s[:title],
        rows: s[:rows].replace_keys({payload: :id})
      }
    }

    params[:header] = header unless header.empty?
    params[:footer] = footer unless footer.empty?

    self.push_message(Api::interactive_list(params), :message)
  end

  def url(params)
    self.raw(
        {  
          type: :image,
          image: {          
            link: params[:image],
            caption: "#{params[:title]}\n#{params[:sub_title]}\n#{params[:url]}"
          }
        }
      )
  end

  def location(params)
    self.push_message(Api::location(params), :message)
  end
  
  def image(params)
    # params = params.replace_keys({url: :link})
    if params[:buttons].nil?

      self.raw(
        {  
          type: :image,
          image: {
            link: params[:url],
            caption: params[:caption]
          }
        }
      )

    else

      buttons = params[:buttons]
      buttons = [buttons] if buttons.class == Hash
      buttons = buttons.replace_keys({payload: :id})
      replies = buttons.map do |reply|
        {
          type: :reply,
          reply: reply
        }
      end
      self.raw(
        {  
          type: :interactive,
          interactive: {
            type: :button,
            header: {
              type: :image,
              image: {
                link: params[:url]
              }
            },
            body:{
              text: params[:caption]
            },
            action:{
              buttons: replies
            }
          }
        }
      )

    end

  end

  def video(params)

    if params[:buttons].nil?

      self.raw(
        {  
          type: :video,
          video: {
            link: params[:url],
            caption: params[:caption]
          }
        }
      )

    else

      buttons = params[:buttons]
      buttons = [buttons] if buttons.class == Hash
      buttons = buttons.replace_keys({payload: :id})
      replies = buttons.map do |reply|
        {
          type: :reply,
          reply: reply
        }
      end
      self.raw(
        {  
          type: :interactive,
          interactive: {
            type: :button,
            header: {
              type: :video,
              video: {
                link: params[:url]
              }
            },
            body:{
              text: params[:caption]
            },
            action:{
              buttons: replies
            }
          }
        }
      )

    end

  end  

  def document(params)
    self.push_message(Api::media(:document, params), :message)
  end

  def contact(params)
    self.push_message(Api::contacts(params), :message)
  end



end
end
end
