# NLP Configuration

{% hint style="warning" %}
To configure this section you must have an app created in [Wit.ai ](https://wit.ai)and get the "Server Access Token".
{% endhint %}

The configuration file for the NLP service is located at `config/nlp.rb`

### One Language

```ruby
Kogno::Application.configure do |config|

  config.nlp.wit = {
    enable: false,
    api_version: "20210928",
    apps: {
      default: "WIT_APP_SERVER_TOKEN"     
    }
  }
  
end
```

### Multi-Language

```ruby
Kogno::Application.configure do |config|

  config.nlp.wit = {
    enable: true,
    api_version: "20210928",
    apps: {
      default: "DEFAULT_WIT_APP_SERVER_TOKEN",
      es: "SPANISH_WIT_APP_SERVER_TOKEN",
      fr: "FRENCH_WIT_APP_SERVER_TOKEN"
    }
  }
  
end
```

### Field Description

| Configuration | Description                                                                                 |
| ------------- | ------------------------------------------------------------------------------------------- |
| enable        | Pass <mark style="color:green;">`true`</mark> to enable NLP engine service to your project. |
| api\_version  | The Wit.ai API version.                                                                     |
| apps          | The Wit.ai apps related to the project. One for each language the chatbot will talk.        |
