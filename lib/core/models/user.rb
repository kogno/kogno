class User < ActiveRecord::Base

  has_many :sequences
  has_many :chat_logs
  has_many :scheduled_messages
  has_many :matched_messages
  has_many :actions, foreign_key: :user_id, :class_name => "UserAction"
  has_many :telegram_groups, foreign_key: :inviter_user_id, :class_name => "TelegramChatGroup"
  has_one :messenger_recurring_notification


  attr_accessor :just_created, :vars
  before_create :set_default_for_session_vars

  def set_default_for_session_vars
    self.session_vars = {}
  end

  def type
    :user
  end

  def chat_id
    self.psid
  end

  def fetch_profile_information
    Kogno::FacebookGraph.fetch_user_data(self.psid, self.page_id)
  end


  def reset
    self.exit_context
    self.save
  end

  def mark_last_message_as_read
    self.last_message_read = true
    self.save
  end

  def mark_last_message_as_unread
    self.last_message_read = false
    self.save
  end

  def set_context(context, params={})

    self.context = context
    self.context_params = params.to_json.encode('utf-8')
    self.save

  end

  def set_locale(locale)
    self.locale = locale
    I18n.locale = locale
    self.save
  end

  def get_context_params
    (JSON.parse(self.context_params,{:symbolize_names => true}) rescue {})
  end

  def add_context(context)
    context_a = self.context.to_s.split(Regexp.union(["/","."]))
    context_a.push(context)
    self.context = context_a.join(".")
    self.save
  end


  def exit_context
    self.set_context(nil) if !self.context.nil?
  end


  def self.find_or_create_by_psid(psid,platform,page_id=nil,psid_from_post_comment=nil)
    user = User.find_by_psid(psid)    
    if user.nil?
      begin
        new_user = User.create(psid: psid, platform: platform, page_id: page_id, last_usage_at: Time.now.utc, psid_from_post_comment: psid_from_post_comment)
        user = User.find(new_user.id)
        user.just_created = true
      rescue ActiveRecord::RecordNotUnique => e
        user = User.find_by_psid(psid)
        user.just_created = false 
      end              
    else
      user.just_created = false
      if user.psid_from_post_comment.nil? and !psid_from_post_comment.nil?
        user.psid_from_post_comment = psid_from_post_comment
        user.save
      end
    end
    return user
  end

  def set_last_usage
    self.last_usage_at = Time.now.utc
  end

  def last_usage
    Time.now.utc - self.last_usage_at
  end

  def dummy?
    self.id.nil?
  end

  def first_time?
    self.just_created.nil? ? false : self.just_created
  end

  #Sequences

  def set_sequence(stage, context)
    sequence = sequences.find_by_context(context)
    if sequence.nil?
      sequence = sequences.create(stage:stage, context: context)
    else
      if stage != sequence.stage
        sequence.stage = stage
        sequence.last_hit_at = Time.now.utc
        sequence.last_executed = 0
        sequence.execution_time = nil
      else
        sequence.updated_at = Time.now.utc
      end
      sequence.save
    end
  end

  def exit_sequence(stage, context)
    sequence = self.sequences.where("stage = '#{stage}' and  context = '#{context}'").first
    unless sequence.nil?
      sequence.destroy
      true
    else
      false
    end
  end

  # Session Vars

  def save_session_vars
    self.last_usage_at = Time.now.utc
    new_session_vars = self.vars.to_json.encode('utf-8')
    if self.session_vars != new_session_vars
      self.session_vars = new_session_vars      
    end
    self.save
  end

  def get_session_vars

    self.vars = (JSON.parse(self.session_vars,{:symbolize_names => true}) rescue {})

  end

  def save_current_context
    self.get_session_vars if self.vars.nil?
    unless self.context.to_s.empty?
      self.vars[:saved_context] = {
        context: self.context.to_s,      
        params: self.context_params
      }
    end
  end

  def previous_context
    self.get_session_vars if self.vars.nil?
    self.vars[:previous_context]
  end

  def delete_previous_context
    self.get_session_vars if self.vars.nil?
    self.vars.delete :previous_context
  end

  def log_message(message, message_type = :received)
    if message_type == :post_comment_received
     self.chat_logs.create({
        message_type: message_type,
        body: message.webhook_data.to_json,
        context: self.context,
        message: message.text.to_s[0..1000],
        nlp_entities: (message.nlp.entities.to_json rescue {}),
        new_user: self.first_time?
      })
    else  
      self.chat_logs.create({
        message_type: message_type,
        body: message.webhook_data.to_json,
        context: self.context,
        payload: message.payload,
        payload_params: message.params,
        message: message.text.to_s[0..1000],
        nlp_entities: (message.nlp.entities.to_json rescue {}),
        user_vars: self.session_vars,
        new_user: self.first_time?
      })
    end

  end

  def log_response(response,scheduled=false)
    unless response.message_log.empty?
      response_log = self.chat_logs.create({
        message_type: :sent,
        body: response.message_log.to_json,
        response: response.response_log.to_json,
        context: self.context,
        user_vars: self.vars.to_json,
        scheduled: scheduled
      })
      response.destroy_message_log
      return(response_log)
    end  
  end

  def destroy_scheduled_messages(tag=nil)
    if tag.nil?
      self.scheduled_messages.destroy_all
    else
      self.scheduled_messages.where(tag: tag).destroy_all
    end
  end

  def scheduled_message?(tag)
    if self.scheduled_messages.where(tag: tag).empty?
      return false
    else
      return true
    end
  end

  def reschedule_message(tag, send_at)
    self.scheduled_messages.where(tag: tag).update_all(send_at: send_at)
  end

  def notification
    if @notification.nil?
      self.vars = {}
      case self.platform.to_sym
        when :messenger
          @notification =  Kogno::Messenger::Notification.new(self)
        when :telegram
          @notification =  Kogno::Telegram::Notification.new(self)
        when :whatsapp
          @notification =  Kogno::WhatsApp::Notification.new(self)
      end
    end
    @reply = @notification
    @user = self
    return @notification
  end

  def update_messenger_recurring_notification(data)
    return false unless self.platform == "messenger"
    params = {
      token: data[:notification_messages_token],
      frecuency: data[:notification_messages_frequency],
      expires_at: Time.at(data[:token_expiry_timestamp]/1000),
      token_status: data[:user_token_status],
      timezone: data[:notification_messages_timezone],
      active: data[:notification_messages_status] == "STOP_NOTIFICATIONS" ? false : true    
    }
    if self.messenger_recurring_notification.nil?
      self.messenger_recurring_notification = MessengerRecurringNotification.create(params)
    else
      self.messenger_recurring_notification.update(params)
    end
    self.messenger_recurring_notification
  end

  def messenger_recurring_notification_data
    self.messenger_recurring_notification.data rescue {}
  end

  def subscribed_to_messenger_recurring_notification?
    messenger_recurring_notification_data[:status] == :active ? true : false
  end
  
end
