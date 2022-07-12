class MatchedMessage < ActiveRecord::Base
  self.table_name = "kogno_matched_messages"
  belongs_to :user

end