# WhatsApp Configuration

{% hint style="warning" %}
In order to configure this section, you must first follow these [WhatsApp instructions](https://developers.facebook.com/docs/whatsapp/cloud-api/get-started).
{% endhint %}

The WhatsApp configuration file is located at `config/platforms/whatsapp.rb`

```ruby
Kogno::Application.configure do |config|
  
  config.whatsapp.graph_url = "https://graph.facebook.com/v13.0/"
  config.whatsapp.phone_number_id = "<YOUR WHATSAPP PHONE NUMBER ID>"
  
  config.whatsapp.access_token = "YOUR_ACCESS_TOKEN"

  config.whatsapp.webhook_route = "/webhook_whatsapp"
  config.whatsapp.webhook_verify_token = "<YOUR_VERIFY_TOKEN>"

end
```

### Field Description

| Configuration                          | Description                                                                                                                                 |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| config.whatsapp.graph\_url             | Facebook Graph Url                                                                                                                          |
| config.whatsapp.phone\_number\_id      | The Phone Number ID obtained in your Meta App Settings.                                                                                     |
| config.whatsapp.access\_token          | The Access Token obtained in your Meta App Settings.                                                                                        |
| config.whatsapp.webhook\_route         | The CallBack URL path where WhatsApp Platform will send notifications.                                                                      |
| config.whatsapp.webhook\_verify\_token | WhatsApp Platform token for [verification request](https://developers.facebook.com/docs/whatsapp/cloud-api/get-started#configure-webhooks). |

