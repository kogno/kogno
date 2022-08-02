---
description: Models are classes, They talk to the database, store and validate data.
---

# Models

As in Rails, Kogno uses the [`ActiveRecord`](https://www.rubydoc.info/gems/activerecord) library for this purpose, so the implementation and operation is the same.  So you can check out the official [Rails documentation](https://guides.rubyonrails.org/active\_record\_basics.html) if you want to read more about Models.

## Creating a new Model

Model classes should be created in `bot/models/` directory, where, in most cases, each one should have a corresponding database table. Which was [previously configured](../getting-started/#configure-the-database).

In the example below, we will create  <mark style="color:orange;">`Product`</mark> model in `bot/models/product.rb` file.

For this to work, there must be a table in the database called `products`.

```ruby
class Product < ActiveRecord::Base
end
```

{% hint style="success" %}
### Associations

All the models that are needed can be created (with exception of the predefined by Kogno), defining associations between them.&#x20;

To lear more about associations you can read: [A Guide to Active Record Associations](https://guides.rubyonrails.org/v3.2/association\_basics.html)`.`
{% endhint %}

## Predefined models

In a new project, by default the following models and their corresponding tables are created:

| <mark style="color:orange;">`User`</mark>                           | `users`                                   | Corresponds to users who are having or have had a conversation with the app.                                                                                                  |
| ------------------------------------------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <mark style="color:orange;">`Sequence`</mark>                       | `kogno_sequences`                         | Message queue of the [Sequences](../contexts/sequences.md).                                                                                                                   |
| <mark style="color:orange;">`ChatLog`</mark>                        | `kogno_chat_logs`                         | Stores log of incoming messages/events and replies, if enabled the [project's configuration](../getting-started/configuration.md).                                            |
| <mark style="color:orange;">`ScheduledMessage`</mark>               | `kogno_scheduled_messages`                | [Scheduled Messages ](../scheduled-messages.md)queue.                                                                                                                         |
| <mark style="color:orange;">`LongPayload`</mark>                    | `kogno_long_payloads`                     | It allows the [creation of payloads](../global-methods.md#set\_payload-payload-string-params-hash) with a number of characters greater than those delimited on each platform. |
| <mark style="color:orange;">`MatchedMessage`</mark>                 | `kogno_matched_messages`                  | Used for [updating messages](https://core.telegram.org/bots/api#updating-messages) feature from Telegram.                                                                     |
| <mark style="color:orange;">`MessengerRecurringNotification`</mark> | `kogno_messenger_recurring_notifications` | Stores the user's subscription current status from [Messenger Recurring Notifications](../contexts/blocks/recurring\_notification.md).                                        |
| <mark style="color:orange;">TelegramChatGroup</mark>                | `kogno_telegram_chat_group`               | Store the Telegram groups or channels where [the bot has been included](../contexts/blocks/nlp\_entity.md).                                                                   |
