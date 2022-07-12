module Kogno
class TelegramCtl
  class << self

    def options(a)
      error = false
      case (a[1].to_sym rescue nil)
        when :webhook
          if a[2] == 'start'
            Kogno::Telegram::Api.set_webhook("#{Kogno::Application.config.telegram.webhook_https_server}#{Kogno::Application.config.telegram.webhook_route}", Kogno::Application.config.telegram.webhook_drop_pending_updates)
          elsif a[2] == 'stop'
            Kogno::Telegram::Api.delete_webhook(Kogno::Application.config.telegram.webhook_drop_pending_updates)
          else
            error = true  
          end
        when :set_commands
          puts a[2]
          scope = a[2]
          if scope == "all"
            puts "Aca222"
            Kogno::Telegram::Api.set_all_commands
          elsif Kogno::Telegram::Api.command_valid_scopes.include?(scope.to_sym)
            Kogno::Telegram::Api.set_scope_commands(scope.to_sym)
          else
            error = true
          end
        when :delete_commands
          scope = a[2]
          if Kogno::Telegram::Api.command_valid_scopes.include?(scope.to_sym)
            Kogno::Telegram::Api.delete_commands(scope)
          else
            error = true
          end
        else
          error = true    
      end

      puts %{Usage: 
        kogno telegram 
            webhook start|stop
            set_commands #{Kogno::Telegram::Api.command_valid_scopes.join("|")}|all
            delete_commands #{Kogno::Telegram::Api.command_valid_scopes.join("|")}
      } if error       
    end

  end
end
end
