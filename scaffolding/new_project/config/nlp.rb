Kogno::Application.configure do |config|

  config.nlp.wit = {
    enable: false,
    api_version: "20210928",
    apps: {
      default: "YOUR_WIT_ACCESS_TOKEN"     
    }
  }

  # Several wit projecs for each languages
  
  # config.nlp.wit = {
  #   enable: false,
  #   api_version: "20210928",
  #   apps: {
  #     default: "YOUR_WIT_ACCESS_TOKEN",
  #     es: "YOUR_ES_WIT_ACCESS_TOKEN",
  #     fr: "YOUR_fr_WIT_ACCESS_TOKEN"
  #   }
  # }

end