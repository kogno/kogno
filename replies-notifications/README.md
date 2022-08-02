---
description: >-
  This chapter talks about the different formats used when replying to or
  sending an on-demand notification to a user.
---

# Replies / Notifications

## Usage

### **On-demand**

```ruby
user = User.first
user.notification.text "Hello!"
user.notification.typing 1.second
user.notification.text("How are you today?")
user.notification.send()
```

### As Reply in the Conversation

Using the <mark style="color:blue;">`@reply`</mark> instance, accessible from any [action block](../contexts/blocks/) in a context or in the callbacks from the [`Conversation`](../conversation.md) class.

```ruby
class MainContext < Conversation

  def blocks

    intent "greeting" do
    
      @reply.text "Hello!"
      @reply.typing_on(2)
      @reply.quick_reply(
        "How are you today?",
        [
          {
            title: "I'm good",
            payload: :good
          },
          {
            title: "Had better days",
            payload: :bad
          }
        ]
      )
      
    end
  
  end

end
```

{% hint style="info" %}
For this case, the call to the `send()` method is not necessary, since it_'s_ a reply within the conversation, therefore the framework will do it automatically.
{% endhint %}

## Notification Formats

{% hint style="success" %}
In Kogno, we try to **unify** as many formats as possible, in order to allow developers to write a unified code for a **cross-platform** conversational application.
{% endhint %}

| Format                                                                      | Description                                                       | Platforms           |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------- | ------------------- |
| ``[`text`](text.md)``                                                       | Text message                                                      | All                 |
| ``[`button`](button.md)``                                                   | Text message with one or more buttons.                            | All                 |
| [`quick_reply`](quick\_reply.md)``                                          | Text message with one or more buttons below.                      | All                 |
| [`raw`](raw.md)``                                                           | Calls to each platform with raw params.                           | All                 |
| [`list`](list.md)``                                                         | Multiple choice list.                                             | WhatsApp            |
| ``[`carousel`](carousel.md)``                                               | Carrousel images, title, description, link, among others.         | Messenger           |
| [`url`](url.md)``                                                           | Url with image, title and description.                            | All                 |
| ``[`typing`](typing.md)``                                                   | Pause for X seconds.                                              | All                 |
| ``[`image`](image.md)``                                                     | Sends an image.                                                   | All                 |
| ``[`video`](video.md)``                                                     | Sends a video.                                                    | All                 |
| [`html`](html.md)``                                                         | Message in HTML format.                                           | Telegram            |
| [`markdown`](markdown.md)``                                                 | Message in Markdown format.                                       | Telegram            |
| ``[`contact`](contact.md)``                                                 | Contact information.                                              | WhatsApp & Telegram |
| ``[`location`](location.md)``                                               | Sends a location.                                                 | WhatsApp & Telegram |
| ``[`recurring_notification_request`](recurring\_notification\_request.md)`` | Request for subscription to recurring notifications in Messenger. | Messenger           |
| ``[`messenger_generic_template`](messenger\_generic\_template.md)``         | The generic template from Messenger.                              | Messenger           |
| ``[`whatsapp_template`](whatsapp\_template.md)``                            | WhatsApp media message template.                                  | WhatApp             |
