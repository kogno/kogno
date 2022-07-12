module Kogno
module Telegram

class Api

  require 'uri'
  require 'net/http'
  require 'openssl'

  class << self

    def request(body,type,method=:post) # :messages, :messenger_profile

      url = URI("#{Kogno::Application.config.telegram.api_url}/#{Kogno::Application.config.telegram.token}/#{type}")
      
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

    def set_webhook(webhook, drop_pending_updates=true)
      body = {
        url: webhook,
        drop_pending_updates: drop_pending_updates
      }
      logger.write_json body, :blue
      request(body.to_json, "setWebhook")
    end

    def delete_webhook(drop_pending_updates=true)
      request(
        {
          drop_pending_updates: drop_pending_updates
        }.to_json,
        "deleteWebhook"
      )
    end

    def send(recipient_id,message, type="sendMessage")
      body = {
        chat_id: recipient_id
      }.merge(message).to_json

      return(self.request(body,type))

    end

    def answer_inline_query(inline_query_id, results, extra_params={})
      body = {
        inline_query_id: inline_query_id,
        results: results
      }.merge(extra_params)
      logger.write_json body, :blue
      return(self.request(body.to_json,"answerInlineQuery"))

    end

    def set_commands(commands,scope, lang=nil)
      valid_scopes = self.command_valid_scopes
      raise "Error, invalid scope. Must be one of these:  #{valid_scopes.join(",")}" unless valid_scopes.include?(scope)
      body = {
        commands: commands.map{|command, description| {command: command, description: description}},
        scope: {
          type: scope
        }
      }          
      body[:language_code] = lang unless lang.nil?
      logger.write "SET COMMAND"  
      logger.write_json body, :blue
      return(self.request(body.to_json, "setMyCommands"))
    end

    def set_all_commands
      Kogno::Application.config.telegram.commands.each do |conf|
        set_commands(conf[:commands], conf[:scope], conf[:lang])
      end
    end

    def set_scope_commands(scope)
      Kogno::Application.config.telegram.commands.each do |conf|        
        set_commands(conf[:commands], conf[:scope], conf[:lang]) if scope == conf[:scope]
      end
    end

    def delete_commands(scope, lang=nil)
      body = {
        scope: {
          type: scope
        }
      }
      body[:language_code] = lang unless lang.nil?
      logger.write "DELETE COMMAND"  
      logger.write_json body, :blue
      return(self.request(body.to_json, "deleteMyCommands"))
    end


    def command_valid_scopes
      [:default, :all_private_chats, :all_group_chats, :all_chat_administrators]
    end 

    def answer_callback_query(callback_query_id, params={})
      body = {
        callback_query_id: callback_query_id
      }.merge(params).to_json
      return(self.request(body,"answerCallbackQuery"))
    end

    def text(text, settings={})

      result = {
        :text => text
      }

      result = result.merge(self.add_remove_keyboard_reply_markup) if settings[:remove_keyboard]

      result

    end

    def inline_keyboard_markup(text,replies, update={})

      result = {
        text: text,
        disable_web_page_preview: true,
        reply_markup: { 
          inline_keyboard: replies.first.class == Array ? replies : [replies] # needs to be an array of arrays
        }        
      }

      result = result.merge(update) unless update.nil?

      result

    end

    def add_inline_keyboard_markup(replies)
        {
          reply_markup: { 
            inline_keyboard: replies # needs to be an array of arrays
          } 
        }  
    end

    def keyboard(text, buttons, one_time_keyboard=true) #type can be: :contact or :location 
      {
        text: text,
        disable_web_page_preview: true,
        reply_markup: { 
          keyboard: buttons.first.class == Array ? buttons : [buttons], # needs to be an array of arrays
          one_time_keyboard: one_time_keyboard
        }
      }
    end

    protected

    def add_remove_keyboard_reply_markup
      {
        reply_markup: { 
          remove_keyboard: true
        }        
      }
    end

    def add_reply_markup(settings)
      reply_markup = {}
      reply_markup[:inline_keyboard] = settings[:inline_keyboard]
    end

  end  

end

end
end