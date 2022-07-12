require 'uri'
require 'net/http'
require 'openssl'

module Kogno
  class ErrorHandler
    class << self

      def notify_by_slack(username, error, token)
        
        error_message = %{```
Error Message: #{error.message[0..256]}
Error Token: #{token}
Backtrace:#{error.backtrace.join("\n\t")[0..1024]}
```}
        
        url = URI(Kogno::Application.config.error_notifier.slack[:webhook])
        
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/json'
        request.body = {
          username: username,
          text: error_message
        }.to_json
        
        response = http.request(request)
        logger.write "-- This error was notified in Slack ---", :red
      end

    end
  end
end