class ScheduledMessage < ActiveRecord::Base
  self.table_name = "kogno_scheduled_messages"
  belongs_to :user

  def self.process_all(sleep=60)
    loop do
      scheduled_messages = where("'#{Time.now.utc}' > send_at").includes(:user).order(:send_at)
      scheduled_messages.each do |scheduled_message|
        if scheduled_message.user.last_usage > Kogno::Application.config.sequences.time_elapsed_after_last_usage
          scheduled_message.execute
        else
          logger.write "User ID #{scheduled_message.user.psid} wrote us recently, let's wait #{Kogno::Application.config.sequences.time_elapsed_after_last_usage - scheduled_message.user.last_usage} seconds before bother him.", :green
        end
      end
      scheduled_messages.destroy_all
      sleep(sleep)
    end
  end

  def execute
    if self.user.platform == "messenger"
      notification = Kogno::Messenger::Notification.new(self.user)
    elsif self.user.platform == "telegram"
      notification = Kogno::Telegram::Notification.new(self.user)
    elsif self.user.platform == "whatsapp"
      notification = Kogno::WhatsApp::Notification.new(self.user)
    else
      logger.write "Platform '#{self.user.platform} not supported. User ID: #{self.user.id}"
      notification = nil
    end
    unless notification.nil?
      notification.import_messages(self.messages)
      logger.write "Sending scheduled messages to #{self.user.psid}..", :green
      logger.write_json JSON.parse(self.messages), :bright
      notification.send
      self.user.log_response(notification,true) if Kogno::Application.config.store_log_in_database
    end
  end

end
