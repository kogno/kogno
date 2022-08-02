---
description: >-
  Kogno is an open source framework running on the Ruby programming language for
  developing chatbots.
---

# Introduction

It is based on the [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) pattern and strongly inspired by [Rails](https://rubyonrails.org/), so if you have ever worked on this framework, Kogno will be very familiar to you.&#x20;

{% hint style="success" %}
Currently, with Kogno you can develop conversational applications in Messenger, WhatsApp and Telegram, maintaining a **unified code** in a single application for all of them.
{% endhint %}

## It's all About the Conversation.

As Kongo was created to develop conversational applications, many definitions, elements and methods were adopted from conversational concepts.

One of the most important concepts are the **contexts**, where most of the conversational logic will reside in an application, developed with this framework.

When a user sends a message, Kogno will determine the context of the conversation. In this context would reside the logic for processing the message and eventually send a reply to the user and/or even move the conversation **** to another context if it's necessary.

![](.gitbook/assets/kogno\_conversation\_diagram.jpg)

## What does a Context look like in Kogno?

A context in Kogno is represented by a <mark style="color:orange;">`class`</mark>, where a series of [code blocks](contexts/blocks/) are defined, one for each type of message or event expected.

When a message/event arrives, only one of these blocks will be executed, if the characteristics of the message matches with the block's execution criteria.

In the example below,  <mark style="color:orange;">`MainContext`</mark> will have the ability to handle the following scenarios:

* ``[`intent`` `<mark style="color:blue;">`"greeting"`</mark>](contexts/blocks/intent.md): A greeting message such as <mark style="color:blue;">"Hello"</mark> or <mark style="color:blue;">"Hi"</mark>. Which was previously created and trained on the NLP engine.
* ``[`postback`<mark style="color:blue;">`"featured_products"`</mark>](contexts/blocks/postback.md):  Click event on the button <mark style="color:blue;">`"View Products"`</mark> that have been sent as reply in the previous block `intent`` `<mark style="color:blue;">`"greeting"`</mark>.&#x20;
* ``[`keyword [`<mark style="color:blue;">`"stop"`</mark>`,`` `<mark style="color:blue;">`"quit"`</mark>`]`](contexts/blocks/keyword.md) : Specifically two keywords <mark style="color:blue;">"stop"</mark> or "<mark style="color:blue;">quit"</mark>.
* ``[`everything_else`](contexts/blocks/everything\_else.md): Any message whose characteristics didn't match the execution criteria of the blocks explained above.

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

## Parallel with Rails

For best understanding, this introductory chapter will draw a parallel with MVC pattern and Rails.&#x20;

After creating a new project by running <mark style="color:purple;">`kogno new your_project`</mark> in the terminal, the initial directory structure will contain several directories that will be explained in the following chapters, but the part we'll draw the parallel, is on the `bot/` directory.

```
├── bot
│   ├── contexts
│   │   └── main_context.rb
│   ├── templates
│   │   └── main
│   ├── models
│   │   └── user.rb
│   ├── conversation.rb
```

### `contexts/` (Controller in Rails)

The term **"context"** used in Kogno would be the equivalent of what the **"controller"** is in Rails.

Just as in an <mark style="color:orange;">`ActionController`</mark> class in Rails, the logic that coordinates the interactions between a user visiting a web, with views and models is written in files such as `products_controller.rb`, `purchases_controller.rb` and so on.

In a <mark style="color:orange;">`Context`</mark> class in Kogno, the logic that coordinates the interactions between an user who sends a message, with the templates and the models, are also written in files such as`products_context.rb`, `purchases_context.rb` or `main_context.rb` (created by default).

{% hint style="success" %}
### Routes

Just as in Rails, requests to a certain URL on a website can be handled by a particular `controller`, in Kogno you can also route messages and events to a particular context.&#x20;

Check [Routing section](contexts/routing.md) for more information.
{% endhint %}

### `templates/`(Views in Rails)

In a conversational application there are no views like in Rails, but there are reply messages, which could be defined in files with an <mark style="color:purple;">`.erb`</mark> extension in directories like `bot/templates/main` (created by default), `bot/templates/products` and `bot/templates/purchases`.

#### Template creation

The example template below is created in `bot/templates/main/menu.erb` file and will expect two parameters: `message` and `buttons_message` which will be explained below.

```ruby
<%  
  @reply.text message
  @reply.typing 1.second
  @reply.button(
    buttons_message,
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
%>
```

#### Use of templates

To use a template, the [<mark style="color:orange;">`@reply.template()`</mark>](templates.md)  method must be called, which would be the equivalent of the [<mark style="color:orange;">`render()`</mark>](https://guides.rubyonrails.org/layouts\_and\_rendering.html#using-render) method in Rails.&#x20;

#### <mark style="color:orange;">`template(route=String, params=Hash)`</mark>

In the example below you can see how the same template <mark style="color:blue;">`"main/menu"`</mark> is used in different situations in the conversation, such as when the user sends a message like "Hi" , "Thank you" or even when the app hasn't understood what the user has said.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do 
    
      @reply.template("main/menu",
        {
          message: "Hello!",
          buttons_message: "How can I help you today?"
        }
      )
      
    end 

    intent "thanks" do 
    
      @reply.template("main/menu",
        {
          message: "You're welcome!",
          buttons_message: "Is there anything else I can help you with?"
        }
      )
      
    end

    everything_else do
    
      @reply.template("main/menu",
        {
          message: "Sorry, but I don't understand what you said.",
          buttons_message: "Maybe I can help you with this.."
        }
      )
      
    end
  
  end

end
```

### `models/` (Model in Rails)

The way this section works doesn't change at all from Rails, since the [`ActiveRecord`](https://www.rubydoc.info/gems/activerecord) library is also used in Kogno.&#x20;

In a new project, <mark style="color:orange;">`User`</mark> (database table `users`) is a model that by default is already created in `bot/models/users.rb` file.

```ruby
class User < ActiveRecord::Base
end
```

{% hint style="warning" %}
When an incoming message arrives from a user, the framework will automatically create a record with the user's information in the `users` table in database.&#x20;
{% endhint %}

#### Use in the conversation

Within a block or template, <mark style="color:blue;">`@user`</mark> can be called, since this is the instance of the `User` model for the message sender.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do 
    
      unless @user.first_name.nil?
        @reply.text "Hello #{@user.first_name}!"
      else
        @reply.text "Hello!"
      end

      case @user.platform
        when "messenger"
          @reply.text "You're in Messenger"
        when "whatsapp"
          @reply.text "You're in WhatsApp"
        when "telegram"
          @reply.text "You're in Telegram"
      end
      
    end 
      
  end

end
```

Read more about fields and methods of the User model [here](models/user-model.md).

{% hint style="info" %}
All the models needed can be created and make the necessary association between them and/or with `User` model.&#x20;

Read more about `ActiveRecord` in the [official documentation](https://www.rubydoc.info/docs/rails/3.1.1/ActiveRecord/Base).
{% endhint %}

### `conversation.rb` (application\_controller.rb in Rails)

Last but not least, the <mark style="color:orange;">`Conversation`</mark> class, which would be equivalent to <mark style="color:orange;">`ApplicationController`</mark> class in Rails.&#x20;

All contexts inherit from this class and the entire conversation goes through it.&#x20;

In it, global logics or validations of the conversation could be defined by calling callbacks.

```ruby
class Conversation < Kogno::Context

  before_blocks :do_something_before_blocks
  after_blocks :do_something_after_blocks

  def do_something_before_blocks
    # This will be called before the blocks method in the current context will be executed
  end

  def do_something_after_blocks
    # This will be called after the blocks method in the current context will be executed
  end

end
```

## Service Integrations&#x20;

### Messaging Platforms Supported

* [Messenger](getting-started/messenger-configuration.md)
* [Telegram](getting-started/telegram-configuration.md)
* [WhatsApp](getting-started/whatsapp-configuration.md)

### **Natural language processing** (NLP)&#x20;

* [Wit.ai](https://wit.ai)

### Database

A project in Kogno needs to be connected to a database, which will contain the tables associated with the models through the [`ActiveRecord`](https://www.rubydoc.info/gems/activerecord) library.

* MySQL

### Error Notification

* [Slack](https://slack.com)

## About this project

Kogno was designed and developed by Martín Acuña Lledó ([@maraculle](https://twitter.com/maraculle)).

This project was backed by [Start Node](http://startnode.com/en) and my family.

### The Goal

The main goal is to get Kogno adopted as an open-source alternative for developing conversational applications, while also being able to create value-added services around this framework on [kogno.io](http://kogno.io) website.

### Contribute

You can contribute a lot to this project by developing conversational applications with Kogno and in case you find a bug, [please report it](https://github.com/kogno/kogno/issues).

And if you're as passionate about it as we are, come and [code with us on GitHub](https://github.com/kogno/kogno) by fixing bugs, adding more integrations and creating more features.

{% hint style="success" %}
### Demo  App

Learn to develop in Kogno by downloading the source code of a flight booking chatbot developed with this framework at [https://github.com/kogno/travel\_chatbot](https://github.com/kogno/travel\_chatbot)
{% endhint %}
