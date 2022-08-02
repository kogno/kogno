---
description: This section explains how to install Kogno and create a new project.
---

# Getting Started

## Installation

_Kogno requires Ruby version 2.7.0 or later._&#x20;

```bash
gem install kogno
```

#### Alternatively for quick installation

```bash
gem install --no-document kogno
```

## Create a new project

```bash
kogno new your_chatbot
```

#### If everything is ok you should see this output:

```bash
A new project has been created at ./your_chatbot
Next steps:
  - cd ./your_chatbot/
  - bundle install
  - Configure your database -> config/database.yml
  - run kogno install
```

### A new project directory tree

```bash
├── Gemfile
├── application.rb
├── bot
│   ├── contexts
│   │   └── main_context.rb
│   ├── conversation.rb
│   ├── helpers
│   ├── models
│   │   └── user.rb
│   └── templates
│       └── main
├── config
│   ├── application.rb
│   ├── database.yml
│   ├── initializers
│   ├── locales
│   │   ├── en.yml
│   │   └── es.yml
│   ├── nlp.rb
│   └── platforms
│       ├── messenger.rb
│       ├── telegram.rb
│       └── whatsapp.rb
├── lib
├── logs
├── tmp
└── web
    ├── public
    ├── routes.rb
    └── views
```

## Installing dependencies

{% hint style="danger" %}
The MySQL development libraries must be previously installed before running the following command.
{% endhint %}

```bash
bundle install
```

## Configure the database

Open the file `config/database.yml` and configure your database.

```yaml
adapter: mysql2
pool: 5
username: your_user_name
password: your_password
host:  localhost
database: your_database_name
encoding: utf8mb4
collation: utf8mb4_unicode_ci
```

### Create framework's tables in database

```bash
kogno install
```

If the database is correctly configured you will see this output:

```
Creating tables..
   users
   kogno_sequences
   kogno_chat_logs
   kogno_scheduled_messages
   kogno_matched_messages
   kogno_telegram_chat_groups
   kogno_long_payloads
   kogno_messenger_recurring_notifications

Now, you can configure:
   config/application.rb

Also some or all these platforms:
  config/platforms/messenger.rb 
  config/platforms/telegram.rb 
  config/platforms/whatsapp.rb 
  config/nlp.rb
```

## Testing in console

The [`console`](../command-line.md#console) command lets you interact with your Kogno application from the command line.&#x20;

To initialize it:

```bash
kogno console
```

Once the console has been opened, any class, instance or function declared in the project can be called.

```ruby
Loading production environment (Kogno 1.0.1)
2.7.0 :001 > user = User.first
2.7.0 :002 > user.notification.text "Hello World!"
2.7.0 :003 > user.notification.send
```
