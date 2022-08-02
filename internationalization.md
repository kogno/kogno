---
description: >-
  The I18n library is already integrated in Kogno, so the development of a
  multi-language chatbot is relatively easy.
---

# Internationalization

## Configuration

### Default locale

The default locale can be set editing the configuration `config.default_locale` in [`config/application.rb`](internationalization.md#configuration) file.

### Setup locales

Kogno will load automatically all `.yml` files located in the folder `config/locales/` .

All necessary  locales files can be created. Being one for each language supported by the chatbot.

## Examples

#### English: `config/locales/en.yml`

```ruby
en:
  hello:
    - "Hello"
    - "Hi"
  hello_name:
    "Hello %{name}!"

  goodbye:
    "Goodbye 👋"
```

#### Spanish: `config/locales/es.yml`

```ruby
es:
  hello:
    - "Hola!"
    - "¡Hola! 😃"
    
  hello_name:
    "Hola %{name}!"

  goodbye:
    "Adios 👋"    
```

{% hint style="success" %}
If in value there is more than one option, like in the example above, `hello` with options "Hello" and "Hi", Kogno will randomly return a single one.&#x20;

This would help create a less monotonous conversation.
{% endhint %}

## Usage

The global method <mark style="color:orange;">`t()`</mark> (short for <mark style="color:orange;">`I18n.t()`</mark>) can be called anywhere in a project's code.

### <mark style="color:orange;">`t(key=String|Symbol, **interpolation)`</mark>

### Example

```ruby
class MainContext < Conversation
  
  def actions

    intent :gretting do
    
      if @user.first_name.nil?
        @reply.text t(:hello)
      else
        @reply.text t(:hello_name, first_name: @user.first_name)
      end
      
    end

    intent :bye do
    
      @reply.text t(:goodbye)
      
    end

  end

end

```

{% hint style="info" %}
Read more examples of `I18n` usage in the [official documentation](https://github.com/ruby-i18n/i18n).
{% endhint %}

## User Locale

By default, the locale of a user starting a conversation for first time will be the one defined in the [chatbot settings](internationalization.md#default-locale), if the platform has not included it in the webhook.

But this can be changed by calling the <mark style="color:orange;">`set_locale()`</mark> from `User` model.

```ruby
@user.set_locale(:es)
```
