---
description: >-
  Contexts are the skeleton of an application developed with Kogno, since in
  these, a large part of the logic of capturing, processing and replying to an
  incoming message is developed.
---

# Contexts

In a given project, all the contexts needed can be created in order to develop a well structured conversation.

{% hint style="info" %}
Making a parallel with Ruby on Rails or the MVC architecture, the contexts would be the equivalent of [controllers](https://guides.rubyonrails.org/action\_controller\_overview.html).
{% endhint %}

## Creating a new Context

A context is represented by a class which is declared as follows:

### <mark style="color:green;">`class`</mark>` ```` `<mark style="color:orange;">`TheContextNameContext`</mark>` ``<`` `<mark style="color:purple;">`Conversation`</mark>

{% hint style="success" %}
### Basic rules to create a new context

1. All contexts created must inherit from the [<mark style="color:purple;">**Conversation**</mark>](../conversation.md) class.
2. The class name must end in <mark style="color:orange;">`Context`</mark>. Ex: `MainContext`, `ProductsContext, PurchaseContext` and so on.
3. All context files must be located in the `bot/contexts/` directory under files with `".rb"` extension. Ex: `the_context_name_context.rb`, `profile_context.rb` ,`people_context.rb` and so on.
{% endhint %}

## Default context: <mark style="color:orange;">`MainContext`</mark>

In a new project, the context <mark style="color:orange;">`MainContext`</mark> is created by default into the file `bot/contexts/main_context.rb`.

This is the **general context** of the conversation and the context by default in a new conversation.

All the logic of capturing, processing and replying to a message from a user that is in a conversation without a context, will be developed here.

{% hint style="info" %}
### Change the default context

The default context can be changed by modifying the `config.routes.message` field in [`config/application.rb`](../getting-started/configuration.md) configuration file.
{% endhint %}

## &#x20;<mark style="color:red;">`blocks()`</mark> method

The <mark style="color:red;">`blocks()`</mark> method is declared in a `Context` class and within it, the [action blocks](blocks/) necessary to capture messages with the characteristics that the context is expecting to handle.

```ruby
class MainContext < Conversation

  def blocks
    
      # Here you will define the action blocks.
      
  end
  
end
```

## Usage Example

In the code below, see how <mark style="color:orange;">`MainContext`</mark> can handle the following scenarios with the declaration of 3 action blocks:

* [`intent "greeting"`](blocks/intent.md) : A greeting messages, such as <mark style="color:blue;">`"Hello"`</mark> or <mark style="color:blue;">`"Hi"`</mark>. If the intent exists and has been trained on the NLP engine.
* [`postback "email_subscription"`](blocks/postback.md): A click event, that occurs when the user clicks on the button <mark style="color:blue;">`"Subscribe Me"`</mark> replied by the block above.
* [`everything_else`](blocks/everything\_else.md): A generic response, in case the message were not any the ones declared above.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do 
      @reply.text "Hello!"
      @reply.button(
        "What can I do for you?",
        [
          {
            title: "Subscribe Me",
            payload: "email_subscription"
          },
          {
            title: "See Featured Products",
            payload "products/featured"
          }
        ]
      )      
    end
    
    postback "email_subscription" do
      @reply.text "Great!"
      @reply.typing 1
      ask "/profile/ask_email"
    end
    
    everything_else do 
      @reply.text "My answers are still a bit limited."
    end

  end
  
end
```

{% hint style="success" %}
The <mark style="color:orange;">`ask()`</mark> method, that together with the block <mark style="color:orange;">`answer`</mark>, focuses and reduces the conversation to achieve a goal. In this case "get the user's email".&#x20;

Read more in the [ask & answers chapter](conversational-forms.md).
{% endhint %}

## Multi-Context conversation

When the logic of the conversation becomes broader, a better distribution of the code will be very helpful.&#x20;

For this reason, it's recommendable to create as many contexts needed, in a similar way to when the controllers are created in the MVC architecture.

### Example

For this example we will create a new context called <mark style="color:orange;">`ProductsContext`</mark> in `bot/contexts/products_context.rb`.

```ruby
class ProductsContext < Conversation

  def blocks
  
    postback "featured" do
      products = Product.where(featured: true).limit(10)
      @reply.text "Here you can see our featured products 👇"
      @reply.template "products/carousel", products: products
    end

  end
  
end
```

And remembering the first example above, in the hypothetical scenario in which a user clicks on the second button <mark style="color:blue;">`"See Featured Products"`</mark> (payload: `"products/featured"`) that has been sent as reply in the block `intent "greeting"`.

The click event will delegated in order to be handled by the `ProductsContext`, since the payload contains a route to this context. Learn more about this in [Context Routing chapter](routing.md).

## Moving between contexts

These methods are used to take the conversation from one context to another:

### <mark style="color:orange;">`change_to(route=String, params=Hash)`</mark> <a href="#change_to" id="change_to"></a>

Changes the context of the conversation, from the current context to another context or [sub-context](sub-contexts.md).

After this method is called, all incoming messages from a particular user will be captured by the context defined in the <mark style="color:orange;">`route`</mark> argument, and this context will remain active until the context changes again or <mark style="color:orange;">`exit_context()`</mark> method were called.

#### Usage

Change to other context:

```ruby
change_to "some_context_name"
```

Change to a sub context from other context:

```ruby
change_to "some_context_name/sub_context_name"
```

Change to a sub context in the same context

```ruby
change_to "./sub_context_name"
```

Change From a sub context to his parent context:

```ruby
change_to "../sub_context_name"
```

#### Params

| Name                                                                                                                   | Description                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>route</code></mark><br><mark style="color:orange;"><code></code></mark>String</p> | <p><strong>Required.</strong></p><p>Contains a context's name of a path to a context or sub-context.</p>                                                                                                |
| <p><mark style="color:orange;"><code>params</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p>  | <p><strong>Optional.</strong><br><strong></strong>Only available for sub-contexts. It sends parameters to the sub-context defined. Read more in <a href="sub-contexts.md">sub-contexts</a> chapter.</p> |

### <mark style="color:orange;">`delegate_to(route=String, args=Hash)`</mark> <a href="#delegate_to" id="delegate_to"></a>

It delegates the handling of the incoming message to a context or sub-context, but without the conversation changing context.

#### Usage

```ruby
delegate_to "some_context_name_or_path", ignore_everything_else: false
```

{% hint style="info" %}
The format of the route argument is the same as with the <mark style="color:orange;">`change_to()`</mark> method.
{% endhint %}

#### Params

| Name                                                                                                                   | Description                                                                                                                                                                                                                                                                                                     |
| ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <p><mark style="color:orange;"><code>route</code></mark><br><mark style="color:orange;"><code></code></mark>String</p> | <p><strong>Required.</strong></p><p>Contains a context's name of a path to a context or sub-context.</p>                                                                                                                                                                                                        |
| <p><mark style="color:orange;"><code>args</code></mark><br><mark style="color:orange;"><code></code></mark>Hash</p>    | <p><strong>Optional.</strong></p><p>If <code>ignore_everything_else</code> is <mark style="color:green;"><code>true</code></mark>, it will not execute the everything_else block, if it exists in the delegate context. By default <mark style="color:red;"><code>false</code></mark>.<br><strong></strong></p> |

### <mark style="color:orange;">`exit_context()`</mark>

Exits the current context and takes the conversation to the default context.

#### Usage

```ruby
exit_context()
```

### <mark style="color:orange;">`keep()`</mark>

Keeps the conversation in the delegated context. Whether it was delegated by [context routing](routing.md) or by calling the <mark style="color:orange;">`delegate_to()`</mark> method.

#### Usage

```ruby
keep()
```
