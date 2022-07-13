# Kogno
Kogno is an open source framework running on the Ruby programming language for developing conversational applications.

It is based on the [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) architecture and strongly inspired by Rails, so if you have ever worked on this framework, Kogno will be very familiar to you.

> #### Supported Platforms
> Messenger, WhatsApp and Telegram, maintaining a unified code in a single application for all of them.

You can read the full documentation here https://docs.kogno.io or continue here.

## Getting Started

#### 1. Install Kogno gem:

        $ gem install kogno
        
#### 2. At the command prompt, create a new Kogno application:

        $ kogno new my_chatbot
        
#### 3. Change directory to `my_chatbot` and install the dependencies:
> The MySQL development libraries must be previously installed before running the following command.   

        $ bundle install
        
#### 4. Configure the database at `config/database.yml`:

```ruby
adapter: mysql2
pool: 5
username: your_user_name
password: your_password
host:  localhost
database: your_database_name
encoding: utf8mb4
collation: utf8mb4_unicode_ci
```

#### 5. Create framework's tables in database:

        $ kogno install
        
#### 6. Start your web server to receive incoming updates via an outgoing webhook from the messaging platforms:

        $ kogno http start
> ##### In order to receive webhooks you must configure the messaging platforms:
> - [Configure WhatsApp](https://docs.kogno.io/installation/whatsapp-configuration)
> - [Configure Telegram](https://docs.kogno.io/installation/telegram-configuration)
> - [Configure Messenger](https://docs.kogno.io/installation/messenger-configuration)

## How an app written in Kogno looks like?

The code below represents a `Context` class, which is the equivalent of a `Controller` class in Ruby on Rails:

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do
    
      @reply.text "Hello!"
      @reply.button(
        "How can I help you today?",
        [
          {
            title: "View Products",
            payload: "featured_products"
          },
          { 
            title: "My Cart",
            payload: "purchases/view_cart"
          }
        ]
      )
      
    end
    
    postback "featured_products" do
    
      @reply.text "Alright."
      @reply.template "products/featured", title: "Here is a list of today's featured products."
      
    end
    
    keyword ["stop", "quit"] do
    
      @reply.text "Alright"
      @reply.typing 2.seconds
      @reply.text "I'll stop writing you now.."
      
    end
    
    everything_else do 
    
      @reply.text "Sorry, but I don't understand what you said."
      
    end

  end

end
```

In the example above, `MainContext` has the ability to handle the following scenarios:

- [`intent "greeting"`](https://docs.kogno.io/contexts/actions/intent): A greeting message such as "Hello" or "Hi". Which was previously [created and trained on the NLP engine](https://docs.kogno.io/installation/nlp-configuration).
- [`postback"featured_products"`](https://docs.kogno.io/contexts/actions/postback):  Click event on the button "View Products" that have been sent as reply in the previous block intent "greeting".
- [`keyword ["stop", "quit"]`](https://docs.kogno.io/contexts/actions/keyword): Specifically two keywords "stop" or "quit".
- [`everything_else`](https://docs.kogno.io/contexts/actions/everything_else): Any message whose characteristics didn't match the execution criteria of the scenarios listed above.

## Contribute

You can contribute a lot to this project by developing conversational applications with Kogno and in case you find a bug, [please report it](https://github.com/kogno/kogno/issues).

And if you're as passionate about it as we are, come and code with us by fixing bugs, adding more integrations and creating more features.

## License

Kogno is released under the [MIT License](https://opensource.org/licenses/MIT).

> 
> ## Read the full documentation at http://docs.kogno.io
>         





