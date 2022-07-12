Kogno::Application.configure do |config|
  
  config.whatsapp.graph_url = "https://graph.facebook.com/v13.0/"
  config.whatsapp.phone_number_id = "<YOUR WHATSAPP PHONE NUMBER ID>"
  
  config.whatsapp.access_token = "YOUR_ACCESS_TOKEN"

  #Webhook 
  config.whatsapp.webhook_route = "/webhook_whatsapp"
  config.whatsapp.webhook_verify_token = "<YOUR_VERIFY_TOKEN>"


end
