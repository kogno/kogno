
require 'kogno'
require 'core/loaders/config_files'

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/cross_origin'
require 'json'

Logger.set(:webhook) if ARGV[0] == "daemon"

require File.join(Kogno::Application.project_path,'application.rb')

set :port, Kogno::Application.config.http_port || 1337
set :bind, '0.0.0.0'
set :root, File.join(Kogno::Application.project_path,'web')
set :public_folder, File.join(Kogno::Application.project_path,'web','public')
set :environment, Kogno::Application.config.environment
set :logging, false

configure do
  enable :cross_origin
end

before do 
  reload!(false) if Kogno::Application.config.environment == :development
end

# before '/*' do
#   allowed_paths = [
#     Kogno::Application.config.messenger.webhook_route, 
#     Kogno::Application.config.telegram.webhook_route, 
#     Kogno::Application.config.whatsapp.webhook_route , 
#     "/"
#   ]
#   unless allowed_paths.include?(request.path_info)
#   $logger.debug_json request.path_info, :red
# end

get "/" do
  Kogno::Application.config.app_name
end

post Kogno::Application.config.messenger.webhook_route do

  request.body.rewind
  params = JSON.parse(request.body.read, {:symbolize_names => true})
  $logger.write "MESSENGER INCOMING WEBHOOK: #{request.fullpath}", :bright
  $logger.debug "PARAMS: #{params}"
  if params[:object] == "page"
    params[:entry].each do |entry|
      events = []
      event_type = nil
      if !entry[:messaging].nil?
        events = entry[:messaging]
        event_type = :message
      elsif !entry[:changes].nil?
        events = entry[:changes]
        event_type = :post_comment
      end    

      unless event_type.nil?
        events.each do |event|
          msg = nil
          if event_type == :message
            unless event[:optin].nil?
              msg = Kogno::Messenger::RecurringNotification.new(event)
            else
              msg = Kogno::Messenger::Message.new(event)
            end
          elsif event_type == :post_comment
            msg = Kogno::Messenger::PostComment.new(event,entry[:id])
          end 
          unless msg.nil?
            Thread.new {
              begin
                msg.handle_event()
              rescue StandardError => e
                $logger.write e.message, :red
                $logger.write "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
              end
            }
          end
        end
      end
    end
    status 200
    "EVENT_RECEIVED"
  else
    status 404
  end

end

get Kogno::Application.config.messenger.webhook_route do

  mode = params["hub.mode"]
  token = params["hub.verify_token"]
  challenge = params["hub.challenge"]
  if !mode.nil? and !token.nil?
    if mode == 'subscribe' and token == Kogno::Application.messenger.webhook_verify_token
      status 200
      challenge
    else
      status 403
    end
  end

end

post Kogno::Application.config.telegram.webhook_route do
  request.body.rewind
  params = JSON.parse(request.body.read, {:symbolize_names => true})
  $logger.write "TELEGRAM INCOMING WEBHOOK: #{request.fullpath}", :bright
  $logger.debug "PARAMS: #{params}"

  message = {data: params[:message], type: :message} if !params[:message].nil?
  message = {data: params[:callback_query], type: :callback_query} if !params[:callback_query].nil? and message.nil?
  message = {data: params[:inline_query], type: :inline_query} if !params[:inline_query].nil? and message.nil?
  message = {data: params[:my_chat_member], type: :chat_activity} if !params[:my_chat_member].nil? and message.nil?

  if !message.nil?
    msg = nil
    if [:message, :callback_query].include?(message[:type])
      msg = Kogno::Telegram::Message.new(message[:data], message[:type])
    elsif message[:type] == :inline_query
      msg = Kogno::Telegram::InlineQuery.new(message[:data])
    elsif message[:type] == :chat_activity
      msg = Kogno::Telegram::ChatActivity.new(message[:data])
    end
    if !msg.nil?
      Thread.new {
        begin
          msg.handle_event()
        rescue StandardError => e
          $logger.write e.message, :red
          $logger.write "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
      }    
      status 200
      "True"
    else
      status 404
    end
  else
    status 404
  end
end

post Kogno::Application.config.whatsapp.webhook_route do
  request.body.rewind
  params = JSON.parse(request.body.read, {:symbolize_names => true})
  $logger.write "WHATSAPP INCOMING WEBHOOK: #{request.fullpath}", :bright
  $logger.debug "PARAMS: #{params}"
  entries = params[:entry]  
  entries.each do |entry|
    entry[:changes].each do |change|    
      msg = nil
      if !change[:value][:messages].nil?
        msg = Kogno::WhatsApp::Message.new(change[:value], :message)
      elsif !change[:value][:statuses].nil?
        msg = Kogno::WhatsApp::StatusMessage.new(change[:value], :message)
      end
      unless msg.nil?
        Thread.new {
          begin
            msg.handle_event()
          rescue StandardError => e
            $logger.write e.message, :red
            $logger.write "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
          end
          $logger.write "\n"
        }        
      end
    end
  end

  status 200
  "EVENT_RECEIVED"
end

get Kogno::Application.config.whatsapp.webhook_route do

  mode = params["hub.mode"]
  token = params["hub.verify_token"]
  challenge = params["hub.challenge"]
  if !mode.nil? and !token.nil?
    if mode == 'subscribe' and token == Kogno::Application.whatsapp.webhook_verify_token
      status 200
      challenge
    else
      status 403
    end
  end

end

require File.join(Kogno::Application.project_path,'web','routes.rb')
