class ChatLog < ActiveRecord::Base
  self.table_name = "kogno_chat_logs"
  belongs_to :user
end
