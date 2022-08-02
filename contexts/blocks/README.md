---
description: >-
  The action blocks make it possible for a contexts to digest an incoming
  message or event with certain characteristics that matches with the execution
  criteria of a given block.
---

# Blocks

They are methods that receive a block of code as a parameter and must be called within the definition of the method <mark style="color:red;">`blocks()`</mark> in a [<mark style="color:orange;">`Context`</mark>](../) class.

All necessary blocks can be added, one for each type of message/event that the context is expecting to receive; where (in most cases) only **one of them will be executed**, if a matches occurs.

## Usage

Below, in the <mark style="color:orange;">`MainContext`</mark> example, we're going to add some blocks and explain how each of them would capture and process an incoming message or event:

* ``[`intent "greeting"`](intent.md):  A greeting messages, such as <mark style="color:blue;">`"Hello"`</mark> or <mark style="color:blue;">`"Hi"`</mark>. If the intent exists and has been trained on the NLP engine.
* ``[`postback "get_started"`](postback.md): A click event on a button with a payload with the value <mark style="color:blue;">`"get_started"`</mark> .
* ``[`regular_expression /([a-z..`](regular\_expression.md): Captures the message, if this contains email address, it will return an array with the occurrences found.
* ``[`any_attachment`](any\_attachment.md): Catches any attachment.
* ``[`keyword`](keyword.md): It will be executed if the incoming message value is <mark style="color:blue;">"stop"</mark>, <mark style="color:blue;">"close"</mark> or <mark style="color:blue;">"quit"</mark>.
* ``[`everything_else`](everything\_else.md): It will be executed in the case of none of the blocks declared above could be executed.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do
      @reply.text "Hello!"
    end

    postback "get_started" do |params|
      @reply.text "Welcome to Kogno framework!"
    end

    regular_expression /([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})/ do |emails|
      @reply.text "You've sent me these emails #{emails.join(',')}"
    end
    
    any_attachment do |attachment_files|
      @reply.text "You've sent me a file"
    end
    
    keyword ['stop','close','quit'] do
      @reply.text "I'll stop now"
    end
    
    everything_else do
      @reply.text "I can't understand what you say yet."
    end

  end

end
```

{% hint style="info" %}
The order in which these blocks are called is irrelevant. The explanation bellow..
{% endhint %}

## The Block Matching Process

This process will search for existing matches between **the characteristics of an incoming message or event**, with the **execution criteria of the called blocks** in the active context of the conversation.&#x20;

If the match occurs, the block will be executed and in most cases this process will stop.

{% hint style="success" %}
The matching process is always performed in the same predefined order, this way each block has a different execution priority.
{% endhint %}

## List of Available Blocks

There is a wide variety of blocks, which are going to be listed in order of execution priority:



| Action                                                     | Definition                                                                                                                                                                           | Supported platforms              |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------- |
| ``[`before_anything`](before\_anything.md)``               | If it's called, It will always be executed, at the beginning of the block matching process.                                                                                          | Messenger, WhatsApp and Telegram |
| ``[`postback`](postback.md)``                              | A click event in a [`button`](../../replies-notifications/button.md), [`quick_reply`](../../replies-notifications/quick\_reply.md) or [`list`](../../replies-notifications/list.md). | Messenger, WhatsApp and Telegram |
| ``[`any_postback`](postback.md#any\_postback-block)``      | Catches any `postback` and returns two parameters. The `postback_payload` and `postback_params`.                                                                                     | Messenger, WhatsApp and Telegram |
| ``[`deek_link`](deep\_link.md)``                           | When a user enters the chat through a link with query string parameters such as `ref` (for Messenger) or `start` (for Telegram).                                                     | Messenger and Telegram.          |
| ``[`command`](command.md)``                                | Captures a Telegram command. Example: /start                                                                                                                                         | Telegram                         |
| ``[`any_attachment`](any\_attachment.md)``                 | Captures any attachment like audio, video, image or any file.                                                                                                                        | Messenger, WhatsApp and Telegram |
| ``[`regular_expression`](regular\_expression.md)``         | Captures a message that matches with a given regular expression and returns an array of matches.                                                                                     | Messenger, WhatsApp and Telegram |
| ``[`keyword`](keyword.md)``                                | Captures one or several keywords.                                                                                                                                                    | Messenger, WhatsApp and Telegram |
| ``[`any_number`](any\_attachment-1.md)``                   | Capture and return an array of all numeric values ​​in a message                                                                                                                     | Messenger, WhatsApp and Telegram |
| ``[`any_text`](any\_attachment-2.md)``                     | Capture any text message.                                                                                                                                                            | Messenger, WhatsApp and Telegram |
| ``[`intent`](intent.md)``                                  | Capture the provided intent, if it was created and trained in the NLP engine.                                                                                                        | Messenger, WhatsApp and Telegram |
| ``[`any_intent`](intent.md#any\_intent-block)``            | Catches any intent and returns the intent as a parameter.                                                                                                                            | Messenger, WhatsApp and Telegram |
| ``[`entity`](entity.md)``                                  | Captures the NLP entity, if it exists and is trained on the NLP engine.                                                                                                              | Messenger, WhatsApp and Telegram |
| ``[`membership`](nlp\_entity.md)                           | Will be executed when the chatbot has been included or removed from a Telegram group or channel.                                                                                     | Telegram                         |
| ``[`recurring_notification`](recurring\_notification.md)`` | Will be executed when a user subscribes or unsubscribes from recursive Messenger notifications.                                                                                      | Messenger                        |
| ``[`everything_else`](everything\_else.md)``               | This block will be executed if none of the called blocks in a given context could be executed.                                                                                       | Messenger, WhatsApp and Telegram |
| ``[`after_all`](nlp\_entity-1.md)``                        | If it is declared, it will always be executed, even if another block has been executed before.                                                                                       | Messenger, WhatsApp and Telegram |

### Execution priority example

To better understand how block matching process works, let's assume the following:

* A user sends a message with the value <mark style="color:blue;">"1"</mark> .
* And the conversation is currently in the context <mark style="color:orange;">`GetNumberContext`</mark>.

```ruby
class GetNumberContext < Conversation

  def blocks

    any_number do |number|
      # This block will not execute, because keyword block 
      # has a higher execution priority. 
      @reply.text "You've send me the number #{number}. Captured by any_number block"
    end
    
    keyword "1" do
      @reply.text "You've send me the number 1. Captured by keyword block"
    end
    
    everything_else do 
      @reply.text "I'm expecting any number to respond something different."
    end
    
  end
  
end
```

As much as `any_number` is called (even first) and its execution condition matches with the message (which is a number), this will not be executed.

<mark style="color:blue;">`keyword "1"`</mark> block will be executed, because it has a higher execution priority than <mark style="color:blue;">`any_number`</mark> block,  and with the execution of the first one, the matching process will be stopped.

## Methods: <mark style="color:orange;">`halt()`</mark> and <mark style="color:orange;">`continue()`</mark>

These methods allows to control the block matching process, they can be called within an action block or in a callback in the [`Conversation`](../../conversation.md) class.

### <mark style="color:orange;">`halt()`</mark>

Stops the block matching process.

#### Usage

```ruby
class MainContext < Conversation

  def actions
  
    before_anything do
      @reply.text "This block normaly doesn't stop the block matching process, but in this case it will do"
      halt()
    end
  
  end
  
end
```

### <mark style="color:orange;">`continue()`</mark>

Allows to the block matching process continues when is called in an action block.

#### Usage

Continuing the example in <mark style="color:orange;">`GetNumberContext`</mark>.&#x20;

By calling this method within <mark style="color:blue;">`keyword "1"`</mark> block, <mark style="color:blue;">`any_number`</mark> block will be executed too.

```ruby
class GetNumberContext < Conversation

  def blocks

    any_number do |number|
      # This block will not execute because keyword has will be executed first. 
      @reply.text "You've send me the number #{number}. Captured by any_number block"
    end
    
    keyword "1" do
      @reply.text "You've send me the number 1. Captured by keyword block"
      continue()
    end
    
    everything_else do 
      @reply.text "I'm expecting any number to respond something different."
    end
    
  end
  
end
```
