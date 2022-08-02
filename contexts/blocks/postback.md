---
description: Captures a click event that contains one or more payloads configured.
---

# postback

{% hint style="info" %}
The click event that is performed by a user can come from a [`button`](../../replies-notifications/button.md), [`quick_reply`](../../replies-notifications/quick\_reply.md) `or` [`list`](../../replies-notifications/list.md)`.`
{% endhint %}

### <mark style="color:orange;">`postback(payload=String|Array, &block)`</mark>

## **Platforms**

<table><thead><tr><th>Platform</th><th data-type="checkbox">Supported</th></tr></thead><tbody><tr><td>Messenger</td><td>true</td></tr><tr><td>WhatsApp</td><td>true</td></tr><tr><td>Telegram</td><td>true</td></tr></tbody></table>

## Usage

The example below shows how 3 different click events will be handled:

* `postback`<mark style="color:blue;">`"get_started"`</mark>:  Click event on [Messenger's Get Started button](https://developers.facebook.com/docs/messenger-platform/discovery/welcome-screen/).&#x20;
* `postback`<mark style="color:blue;">`"yes"`</mark>: Click event on <mark style="color:blue;">"Of course!"</mark> button that has been sent as reply in the previous block.
* `postback`<mark style="color:blue;">`"no"`</mark>: Click event on <mark style="color:blue;">"Not really 🤷🏻‍♂️"</mark> button that has been sent as reply in the first block.

```ruby
class MainContext < Conversation

  def blocks

    postback "get_started" do
    
      @reply.text("Hello!")
      @reply.quick_reply(
        "Is it clear to you how postbacks work?",
        [
          {
            title: "Of course!",
            payload: "yes"
          },
          {
            title: "Not really 🤷🏻‍♂️",
            payload: "no"
          }
        ]
      )   
                
    end
    
    postback "yes" do
    
      @reply.text "Awesome!"
      @reply.text "We've put a lot of effort into writing this documentation 💪"
      
    end
    
    postback "no" do 
    
      @reply.text "No problem, continue reading and you will got it..."
      
    end

  end
  
end
```

## Reading params

The `postback` block can receive parameters that are sent as part of the payload.

Next we will implement the same example as above, but using parameters:

```ruby
class MainContext < Conversation

  def blocks

    postback "get_started" do
    
      @reply.text("Hello!")
      @reply.quick_reply(
        "Is it clear to you how postbacks work?",
        [
          {
            title: "Of course!",
            payload: set_payload("understood", {response: "yes"})
          },
          {
            title: "Not really 🤷🏻‍♂️",
            payload: set_payload("understood", {response: "no"})
          }
        ]
      )  
                 
    end
    
    postback "understood" do |params|
    
      response = params[:response]
      if response == 'yes'
      
        @reply.text "Awesome!"
        @reply.text "We've put a lot of effort into writing this documentation 💪"

      elsif response == 'no'
        @reply.text "No problem, continue reading and you will got it..."
      end
    end

  end
  
end
```

{% hint style="success" %}
### <mark style="color:orange;">**`set_payload()`**</mark>

It is a global method of the framework, it is used to generate a payload with parameters. [Read more](../../global-methods.md#set\_payload-payload-string-params-hash).
{% endhint %}



## `any_postback` block

Catch any `postback` received by a context and returns two parameters `payload` and `payload_params`.

### Usage

```ruby
class MainContext < Conversation

  def blocks

    any_postback do |payload, payload_params|

      if payload == "get_started"
    
        @reply.text("Hello!")
        @reply.quick_reply(
          "Is it clear to you how postbacks work?",
          [
            {
              title: "Of course!",
              payload: "yes"
            },
            {
              title: "Not really 🤷🏻‍♂️",
              payload: "no"
            }
          ]
        )  

      elsif payload == "yes" 

        @reply.text "Awesome!"
        @reply.text "We've put a lot of effort into writing this documentation 💪"

      elsif payload == "no"

        @reply.text "No problem, continue reading and you will got it..."
        
      end
                
    end

  end
  
end
```

{% hint style="success" %}
## Route to context

A `payload` can include a route to a `postback` located in a different context than the current context.

The format of a payload containing a route is as follows:

```ruby
"context_name/payload"
```

Read more about this in [Context Routing chapter](../routing.md#postback).
{% endhint %}
