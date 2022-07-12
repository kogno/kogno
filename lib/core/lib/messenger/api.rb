module Kogno
module Messenger
class Api

  require 'uri'
  require 'net/http'
  require 'json'
  require 'openssl'

  class << self

    def request(body,access_token,type=:messages,method=:post) # :messages, :messenger_profile
      url = URI("#{Kogno::Application.messenger.graph_url}/#{type}?access_token=#{access_token}")

      logger.write "REQUEST TO: #{url}", :pink
      logger.write "SENT: #{JSON.parse(body)}", :blue      

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      case method
        when :delete
          request = Net::HTTP::Delete.new(url)
        else 
          request = Net::HTTP::Post.new(url)
      end    

      request["content-type"] = 'application/json'

      request.body = body

      response = http.request(request)
      # logger.debug_json JSON.parse(body), :green
      response_hash = JSON.parse(response.read_body, {:symbolize_names => true})
      logger.write "RESPONSE: #{response_hash}\n", :light_blue
      return(response_hash)
    end

    def setting(body,page_id=nil)
      access_token = self.get_access_token(page_id)
      self.request(body,access_token,:messenger_profile)
    end

    def setting_delete(fields,page_id=nil)
      access_token = self.get_access_token(page_id)
      self.request({
        fields: fields
      }.to_json,access_token,:messenger_profile, :delete)
    end

    def send_message(recipient_psid,message,messaging_type="RESPONSE",page_id=nil)

      body = {
        messaging_type: messaging_type,
        recipient: {
          id: recipient_psid
        },
        message: message
      }.to_json

      access_token = self.get_access_token(page_id)
      return(self.request(body,access_token))

    end

    def send_message_with_rn_token(notification_token,message,page_id=nil)

      body = {
        recipient: {
          notification_messages_token: notification_token
        },
        message: message
      }.to_json

      access_token = self.get_access_token(page_id)
      return(self.request(body,access_token))

    end


    def send_private_reply(recipient_id,message,page_id=nil)

      body = {
        :recipient => {
          :comment_id => recipient_id
        },
        :message => message
      }.to_json

      access_token = self.get_access_token(page_id)
      return(self.request(body,access_token))
    end



    def send_action(recipient_psid,action,messaging_type="RESPONSE",page_id=nil) # action => mark_seen, typing_on, typing_off
      # body = %{{"recipient":{"id":"#{recipient_psid}"},"sender_action":"#{action}"}}
      body = {
        messaging_type: messaging_type,
        recipient: {
          id: recipient_psid
        },
        sender_action: action
      }.to_json

      access_token = self.get_access_token(page_id)
      return(self.request(body,access_token))
    end

    def text_message(text)

      {
        :text => text
      }
      # return %{{"text":"#{text}"}}

    end


    def attachment_message(attachment)

      {
        attachment: attachment
      }

    end

    def button_template(text,buttons)

      attachment = {
        type: :template,
        payload: {
          template_type: :button,
          text: text,
          buttons: buttons
        }
      }
      return self.attachment_message(attachment)

    end

    def quick_replies(title,replies)

      response = {
        text: title,
        quick_replies: replies
      }

      return response

    end

    def list_template(elements, buttons = [])
      attachment = {
        type: :template,
        payload: {
          template_type: :list,
          top_element_style: :compact,
          elements: elements,
          buttons: buttons
        }
      }

      return self.attachment_message(attachment)

    end

    def generic_template(elements,image_aspect_ratio=:horizontal)

      elements = [elements] unless elements.class == Array

      attachment = {
        type: :template,
        payload: {
          template_type: :generic,
          image_aspect_ratio: image_aspect_ratio,
          elements: elements
        }
      }

      return self.attachment_message(attachment)

    end

    def generic_template_with_replies(elements,image_aspect_ratio=:horizontal, quick_replies)
      message = generic_template(elements,image_aspect_ratio=:horizontal)
      message[:quick_replies] = quick_replies
      return message
    end

    def show_ad_message(message)

      JSON.pretty_generate(
        {
          message: message,
          user_edit: true
        }
      )

    end

    def get_access_token(page_id=nil)

      if page_id.nil?
        Kogno::Application.messenger.pages.first[1][:token]
      else
        Kogno::Application.messenger.pages[page_id][:token] rescue nil
      end

    end

    def persistent_menu(page_id=nil)
      persistent_menu = Kogno::Application.messenger.persistent_menu
      if persistent_menu.nil?
        body = {
          persistent_menu:[
            {
              locale: "default",
              composer_input_disabled: false,
            }
          ]
        }
      else
        body = {
          persistent_menu: persistent_menu
        }
      end
      logger.write_json body, :bright
      self.setting(body.to_json, page_id)
    end

    def get_started_button(page_id=nil)
      body = {
        get_started: {
          payload: Kogno::Application.messenger.welcome_screen_payload
        }
      }
      logger.write_json body, :bright
      self.setting(body.to_json, page_id)
    end

    def ice_breakers(page_id=nil)
      body = {
        ice_breakers: Kogno::Application.messenger.ice_breakers
      }
      logger.write_json body, :bright
      self.setting(body.to_json, page_id)
    end

    def add_domain(domain)
      body = {
        whitelisted_domains: [
          domain
        ]
      }
      logger.write_json body, :bright
      self.setting(body.to_json)
    end

    def update_whitelisted_domains
      body = {
        whitelisted_domains: Kogno::Application.messenger.whitelisted_domains
      }
      logger.write_json body, :bright
      self.setting(body.to_json)
    end
    
    def greeting(page_id=nil)
      body = {
        greeting: Kogno::Application.messenger.greeting
      }
      logger.write_json body, :bright
      self.setting(body.to_json, page_id)
    end

  end

end
end
end
