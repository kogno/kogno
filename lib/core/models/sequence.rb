class Sequence < ActiveRecord::Base
  self.table_name = "kogno_sequences"
  belongs_to :user
  before_create :set_last_hit_at

  def set_last_hit_at
    self.last_hit_at = Time.now.utc
  end

  def route
    "#{context}.#{stage}"
  end


  def self.process_all(sleep=60)
    loop do
      actions = where("'#{Time.now.utc}' > execution_time or execution_time is null").includes(:user).order(:execution_time)
      actions.each do |action|
        if action.user.last_usage > Kogno::Application.config.sequences.time_elapsed_after_last_usage
          Kogno::Context.run_sequence(action)
        else
          logger.write "User ID #{action.user.psid} wrote us recently, let's wait #{Kogno::Application.config.sequences.time_elapsed_after_last_usage - action.user.last_usage} seconds before bother him.", :green
        end
      end
      sleep(sleep)
    end
  end

end
