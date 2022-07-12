Kogno::Application.configure do |config|
  
  config.messenger.graph_url = "https://graph.facebook.com/v2.6/me"
  
  # You can run this chatbot in several Facebook Pages.
  config.messenger.pages = {
    "YOUR_FANPAGE_ID" => {
      name: "YOUR_FANPAGE_NAME",
      token: "YOUR_ACCESS_TOKEN"
    },
    # "YOUR_2ND_FANPAGE_ID" => {
    #   name: "YOUR_2ND_FANPAGE_NAME",
    #   token: "YOUR_2ND_ACCESS_TOKEN"
    # }
  }

  config.messenger.webhook_route = "/webhook_messenger"
  config.messenger.webhook_verify_token = "<YOUR_VERIFY_TOKEN>"
  
  # Default context for any post comment arrived
  config.routes.post_comment = :main

  # Default context for incoming events about subscriptions to recurring notifications
  config.routes.recurring_notification = :main

  #Whitelisted Domains, update by running kogno messenger update_whitelisted_domains
  config.messenger.whitelisted_domains = [
    "kogno.io"
  ]

  #Activate/deactivate by running kogno messenger menu on|off
  config.messenger.persistent_menu =  [
    {
      locale: :default,
      composer_input_disabled: false,
      call_to_actions: [
        {
          title: "Title",
          type: :postback,
          payload: "your_context/a_payload_in_the_context"
        },
        {
          title: "Title2",
          type: :postback,
          payload: "your_payload"
        }
      ]
    }
  ]

  #Activate/deactivate by running kogno messenger get_started on|off
  config.messenger.welcome_screen_payload = "GET_STARTED"

  #Activate/deactivate by running kogno messenger greeting on|off
  config.messenger.greeting = [
    {
      locale: :default,
      text: "Hello word."
    }
  ]

  #Activate/deactivate by running kogno messenger ice_breakers on|off
  config.messenger.ice_breakers = [
    {
      question: "Question 1?",
      payload: "context/payload"
    },
    {
      question: "Question 2",
      payload: "payload_two"
    }
  ]  

end
