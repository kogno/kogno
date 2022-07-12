class LongPayload < ActiveRecord::Base
    self.table_name = "kogno_long_payloads"
    before_create :generate_token    

    def generate_token
      self.token = Digest::MD5.hexdigest "#{Time.now}#{rand(100000)}"
    end

    def self.set(data)
      data = data.split(":",2)
      payload = data[0]
      params = data[1]
      payload_param = create(payload: payload, params: params)
      return payload_param.token
    end

    def self.get(token)
      payload = find_by_token(token)
      unless payload.nil?
        return ("#{payload.payload}:#{payload.params}")
      else
        return {}
      end
    end
end