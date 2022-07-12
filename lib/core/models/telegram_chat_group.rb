class TelegramChatGroup < ActiveRecord::Base
  self.table_name = "kogno_telegram_chat_groups"
  belongs_to :user, foreign_key: :inviter_user_id

  def type
    self.kind.to_sym
  end

  def self.find_or_create(args)
    chat = find_by_chat_id(args[:chat_id])
    if chat.nil?
      chat = create(args)
    else
      chat.update(args)
    end
    return chat
  end

  def notification
    if @notification.nil?
      @notification =  Kogno::Telegram::Notification.new(self)
    end
    @notification
  end
  
end
