---
description: Route an incoming message or event to a specific context of the conversation.
---

# Routing

It's a very useful feature when it comes to decentralizing the handling of incoming messages or events and thus to achieving a more distributed code.

## Postback

A [postback](blocks/postback.md) payload can contain a path to a context, in addition to the information that the payload normally carries.&#x20;

### Examples

#### Route only

```ruby
"context_name/payload"
```

#### With params

```ruby
set_params("context_name/payload", {p1: "value1", p2: "value2"})
```

### Usage

```ruby
class MainContext < Conversation

  def blocks
  
    intent "greeting" do
    
      @rsp.quick_reply(
        "Would you like to sign up?",
        [
          {
            title: "Create an Account",
            payload: "profile/sign_up"
          }
        ]
      )      
      
    end
    
  end
  
end
```

The click event on <mark style="color:blue;">"Create an Account"</mark> button will be handled by the <mark style="color:orange;">`ProfileContext`</mark> which will receive the payload without the context path information.

```ruby
class ProfileContext < Conversation

  def blocks
  
    postback "sign_up" do 
    
      @reply.text "To create a new account please click in the button bellow."
      @reply.url(
        {
          title: "Create a new User",
          url: "https://kogno.io/sign_up"
        }
      )
      
    end
    
  end
  
end
```

## Intent

In order to implement this type of routing. In the NLP engine, just create an intent whose name starts with the name of an existing context in the project, followed by an underscore and the intent's own information. For instance:  <mark style="color:blue;">`profile_sign_up`</mark> , where `profile` is the context and `sign_up` is the intent.

### Intent creation example in Wit.ai

![profile\_sign\_up intent creation in Wit.ai](<../.gitbook/assets/Screen Shot 2022-05-30 at 19.09.28.png>)

![profile\_sign\_up intent training.](<../.gitbook/assets/Screen Shot 2022-05-30 at 19.10.12.png>)

### Usage

The <mark style="color:blue;">`profile_sign_up`</mark> intent will be handled by the ProfileContext and this will be able to capture the <mark style="color:blue;">`"sign_up"`</mark> intent, without path information.

```ruby
class ProfileContext < Conversation

  def blocks
  
    intent "sign_up" do 
    
      @reply.text "To create a new account please click in the button bellow."
      @reply.url(
        {
          title: "Create a new User",
          url: "https://kogno.io/sign_up"
        }
      )
      
    end
    
  end
  
end
```

## Commands (Telegram)

In order to routing [Telegram commands](blocks/command.md), just edit the `config.routes.commands` field in [`config/platforms/telegram.rb`](../getting-started/telegram-configuration.md), adding a line with the format `:command => :context_name` for each command that we want to route.

```ruby
config.routes.commands = {
  :start => :main,
  :sign_up => :profile
}
```

### Usage

```ruby
class ProfileContext < Conversation

  def blocks
  
    command "sign_up" do 
    
      @reply.text "To create a new account please click in the button bellow."
      @reply.url(
        {
          title: "Create a new User",
          url: "https://kogno.io/sign_up"
        }
      )
      
    end
    
  end
  
end
```

{% hint style="info" %}
Commands that have not been configured will be handled by the [default context](./#default-context-maincontext).
{% endhint %}

## Deep Links

A click event on a [deep link](blocks/deep\_link.md) can contain a path to a context, if the value of the params: <mark style="color:purple;">`ref`</mark> (Messenger) or <mark style="color:purple;">`start`</mark> (Telegram), starts with the name of an existing context in a given project.

#### Messenger Example

[https://m.me/kogno.io/ref=profile\_sign\_up](https://m.me/kogno.io/ref=profile\_sign\_up)

#### Telegram Example

[https://t.me/KognoBot?start=profile\_sign\_up](https://t.me/KognoBot?start=profile\_sign\_up)

In both examples, the click events will be be handled by <mark style="color:orange;">`ProfileContext`</mark> and param value will be <mark style="color:blue;">`"sign_up"`</mark>, without path information

```ruby
class ProfileContext < Conversation

  def blocks

    deep_link do |value|
    
      if value == "sign_up"
        @reply.text "To create a new account please click in the button bellow."
        @reply.url(
          {
            title: "Create a new User",
            url: "https://kogno.io/sign_up"
          }
        )    
      end  
      
    end

  end
  
end
```
