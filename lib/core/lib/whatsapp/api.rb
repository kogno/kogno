module Kogno
module WhatsApp

class Api

  require 'uri'
  require 'net/http'
  require 'openssl'

  class << self

    def request(body,type,method=:post) # :messages, :messenger_profile

      url = URI("#{Kogno::Application.config.whatsapp.graph_url}/#{Kogno::Application.config.whatsapp.phone_number_id}/#{type}")

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
      
      request["Authorization"] = "Bearer #{Kogno::Application.config.whatsapp.access_token}"
      request["content-type"] = "application/json"

      request.body = body

      response = http.request(request)
      # logger.debug_json JSON.parse(body), :green
      response_hash = JSON.parse(response.read_body, {:symbolize_names => true})
      logger.write "RESPONSE: #{response_hash}\n", :light_blue
      return(response_hash)

    end


    def send(recipient,message, type="messages")
      body = {
        messaging_product: :whatsapp,
        recipient_type: :individual,
        to: recipient, 
      }.merge(message).to_json

      return(self.request(body,type))

    end

    def template_message(template_name, components=[], lang="en_US")

      {
        type: :template,
        template: { 
          name: template_name, 
          language: { 
            code: lang
          },
          components: components
        } 
      }    

    end

    def interactive_buttons(text, buttons)

      {
        type: :interactive,
        interactive: {
          type: :button,
          body: {
            text: text
          },
          action: {
            buttons: buttons
          }
        }
      }    

    end

    def interactive_buttons(text, buttons)

      {
        type: :interactive,
        interactive: {
          type: :button,
          body: {
            text: text
          },
          action: {
            buttons: buttons
          }
        }
      }    

    end


    def interactive_list(params)

      {
        type: :interactive,
        interactive: {
          type: :list,
          header: params[:header],
          footer: params[:footer],
          body: {
            text: params[:text]
          },
          action: {
            button: params[:button],
            sections: params[:sections]
          }
        }
      }    

    end  

    def location(location_data) 
      {
        type: :location,
        location: location_data
      }
    end
    
    def media(type, params) 
      media_object = {
        type: type       
      }
      media_object[type] = params
      media_object
    end

    def contacts(params)
      {
        type: :contacts,
        contacts: params
      }
    end


  end  

end

end
end