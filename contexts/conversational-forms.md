---
description: >-
  This feature, which includes two methods ask() and answer() allows you to
  create conversational forms.
---

# Conversational Forms

## <mark style="color:orange;">`ask(answer_route=String)`</mark>

This method triggers a question and temporarily narrows the conversation until an expected answer is obtained.

Receives an argument, <mark style="color:orange;">`answer_route`</mark>, which contains the route (in the format <mark style="color:blue;">`"context_name/answer_label"`</mark>), where the logic for the answer resides.

### Usage

```ruby
ask("profile/get_email_address")
```

{% hint style="info" %}
If <mark style="color:orange;">`ask()`</mark> is called in the same [context](./) where the <mark style="color:orange;">`answer()`</mark> method is called, it is not necessary to include the context name in the route.
{% endhint %}

## <mark style="color:orange;">`answer(label=String|Symbol, &block)`</mark>

In this method, the logic for obtaining the expected answer is defined, as well as the exit logic in case the user decides not to answer.

Receives two arguments: <mark style="color:orange;">`label`</mark>, which is the identification of the answer and <mark style="color:orange;">`block`</mark>, where the logic for the answer is defined by calling all necessary [action blocks](blocks/) within it.

Additionally, the <mark style="color:orange;">`ask(&block)`</mark> <mark style="color:orange;"></mark><mark style="color:orange;"></mark> method can be called, which will be executed automatically in the activation of the answer block. Within it the question can be sent to the user.

### Usage

```ruby
class ProfileContext < Conversation

  def blocks

    answer "get_email_address" do 

      ask do
        @reply.text "What is your email?"
      end

      regular_expression /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/ do |emails|
        @reply.text("Good, I'll register you under this email: #{emails.first}")      
        exit_answer()
      end

      keyword "stop" do 
        @reply.text "I'm stopping the sign up process now."
        exit_answer()
      end

      everything_else do
        @reply.text "I need an email in order to continue. Or write 'stop' if you want to cancel"
      end

    end
  
  end
    
end
```

### <mark style="color:orange;">`exit_answer()`</mark>

This method, which must be called within an answer block, returns the conversation to the context it was in before the <mark style="color:orange;">`ask()`</mark> method was called.

{% hint style="info" %}
Another way to exit from an answer block is by calling to the <mark style="color:orange;">`ask()`</mark> method again, but this time with a different `answer_route`.
{% endhint %}

## Full Example

In the following example we will perform a user sign up process, by asking his email, age (optional) and their favorite color.

```ruby
class ProfileContext < Conversation

  def blocks
  
    postback "sign_up" do
      @reply.text "I'll start by asking some information about you.."
      @reply.text "Write 'stop', if you decide to exit from the sign up process."
      @reply.typing 2.seconds
      ask "get_email_address"
    end

    answer "get_email_address" do 

      ask do
        @reply.text "What is your email address?"
      end

      regular_expression /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/ do |emails|
        @reply.text("Good, I'll register you under this email: #{emails.first}")      
        ask "get_his_age"
      end

      keyword "stop" do 
        @reply.text "I'm stopping the sign up process now."
        exit_answer()
      end

      everything_else do
        @reply.text "I need an email address in order to continue."
      end

    end

    answer "get_his_age" do 

      ask do
        @reply.text "The next question is optional, so If you don't want to respond you can write 'next'"
        @reply.typing 1.seconds
        @reply.text "What's your age?"
      end

      any_number do |age|
        @reply.text("This is your age #{age.first}")
        ask "get_favorite_color"
      end

      entity "wit$age_of_person:age_of_person" do |ages|
        age = ages.first[:value]
        @reply.text("This is your age #{age[:value]}")
        ask "get_favorite_color"
      end

      keyword "stop" do 
        @reply.text "I'm stopping the sign up process now."
        exit_answer()
      end

      keyword "next" do
        @reply.text "Alright, next question.."
        ask "get_favorite_color"
      end

      everything_else do
        @reply.text "To cointinue, I need your age."
      end

    end

    answer "get_favorite_color"
      
      ask do 
        @reply.text "What's your favorite color?"
      end

      entity "color:name" do |colors|  
        color = colors.first[:value]
        @reply.text "Alright, this is your color #{color}!"
      end

      keyword "stop" do 
        @reply.text "I'm stopping the sign up process now."
        exit_answer()
      end

      everything_else do
        @reply.text "To cointinue, I need to know your favorirte color."
      end

    end
  
  end

end
```
