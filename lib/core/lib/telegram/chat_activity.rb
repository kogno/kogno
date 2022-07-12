module Kogno
module Telegram
class ChatActivity

  def initialize(data)
    @data = data
  end

  def type
    :chat_activity
  end

  def chat
    @data[:chat]
  end

  def chat_id
    @data[:chat][:id]
  end

  def chat_title
    @data[:chat][:title]
  end

  def chat_type
    @data[:chat][:type]
  end

  def inviter_user_id
    @data[:from][:id]
  end

  def get_kgn_id
    nil
  end

  def chat_perms
    perms = @data[:new_chat_member]
    {
      can_be_edited: perms[:can_be_edited],
      can_manage_chat: perms[:can_be_edited],
      can_change_info: perms[:can_be_edited],
      can_post_messages: perms[:can_be_edited],
      can_edit_messages: perms[:can_be_edited],
      can_delete_messages: perms[:can_be_edited],
      can_invite_users: perms[:can_be_edited],
      can_restrict_members: perms[:can_be_edited],
      can_promote_members: perms[:can_be_edited],
      can_manage_voice_chats: perms[:can_be_edited]
    }
  end

  def chat_membership_status    
    if ["member","administrator"].include?(@data[:new_chat_member][:status])
      return true
    elsif  ["left","kicked"].include?(@data[:new_chat_member][:status])
      return false
    end
  end

  def get_context(user,notification, notification_group,chat=nil)
    # Here you can use different contexts by self.post_id
    context_class = Context::router(Kogno::Application.config.routes.chat_activity)[:class]
    context_route = :main
    context = context_class.new(user,self,notification,context_route, notification_group, chat)
    return(context)
  end

  def handle_event(debug=false)

    begin

      user = User.find_or_create_by_psid(self.inviter_user_id, :telegram)
      self.set_nlp(user.locale)
      I18n.locale = user.locale unless user.locale.nil?
      notification = Notification.new(user,self)
      chat = TelegramChatGroup.find_or_create({
        chat_id: self.chat_id,
        title: self.chat_title,
        kind: self.chat_type,
        inviter_user_id: user.id,
        membership: self.chat_membership_status       
      })

      notification = Notification.new(user,self)
      notification_group = Notification.new(chat,self)

      context = get_context(user,notification, notification_group, chat)
      context.run_for_chat_activity_only

      notification.send
      notification_group.send

      if Kogno::Application.config.store_log_in_database
        user.log_message(self, :chat_activity_received) 
        user.log_response(notification)
      end
     
    rescue StandardError => e
      error_token = Digest::MD5.hexdigest("#{Time.now}#{rand(1000)}") # This helps to identify the error that arrives to Slack in order to search it in logs/http.log      
      logger.write e.message, :red
      logger.write "Error Token: #{error_token}", :red
      logger.write "Backtrace:\n\t#{e.backtrace.join("\n\t")}", :red
      ErrorHandler.notify_by_slack(Kogno::Application.config.app_name,e, error_token) if Kogno::Application.config.error_notifier.slack[:enable] rescue false
    end

  end

end
end
end