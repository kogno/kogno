require 'uri'
require 'net/http'
require 'openssl'

module Kogno
class FacebookGraph
  class << self

    def fetch_user_data(psid,page_id=nil)
      url = URI("https://graph.facebook.com/v3.3/#{psid}/?access_token=#{self.get_access_token(page_id)}&fields=name,first_name,last_name,timezone,locale,profile_pic")
      puts url
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url)
      response = http.request(request)
      return(JSON.parse(response.read_body, {:symbolize_names => true}))
    end

    def get_access_token(page_id=nil)
      if page_id.nil?
        Kogno::Application.messenger.pages.first[1][:token]
      else
        Kogno::Application.messenger.pages[page_id][:token] rescue nil
      end
    end    

  end  


end
end
