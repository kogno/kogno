module Kogno
class MessengerCtl
  class << self

    def options(a)
      page_id = a[3] rescue nil
      case (a[1].to_sym rescue nil)
        when :menu
          if a[2] == 'on'
            Kogno::Messenger::Api.persistent_menu(page_id)
          elsif a[2] == 'off'
            Kogno::Messenger::Api.setting_delete([:persistent_menu])
          end
        when :get_started
          if a[2] == 'on'
            Kogno::Messenger::Api.get_started_button(page_id)
          elsif a[2] == 'off'
            Kogno::Messenger::Api.setting_delete([:get_started], page_id)
          end
        when :update_whitelisted_domains
          Kogno::Messenger::Api.update_whitelisted_domains
        when :ice_breakers
          if a[2] == 'on'
            Kogno::Messenger::Api.ice_breakers()
          elsif a[2] == 'off'
            Kogno::Messenger::Api.setting_delete([:ice_breakers])
          end          
        when :greeting
          if a[2] == 'on'
            Kogno::Messenger::Api.greeting()
          elsif a[2] == 'off'
            Kogno::Messenger::Api.setting_delete([:greting])
          end         
        else
          puts %{Usage: 
            kogno messenger 
                menu on|off
                get_started on|off
                greeting on|off
                ice_breakers on|off                
                update_whitelisted_domains
          }      
      end
    end

  end
end
end
