class MessengerRecurringNotification < ActiveRecord::Base
  self.table_name = "kogno_messenger_recurring_notifications"
  belongs_to :user

  def data
    {
      token: self.token,
      frecuency: self.frecuency,
      expires_at: self.expires_at,
      token_status: self.token_status,
      timezone: self.timezone,
      status: self.active ? :active : :stopped  
    }
  end

end