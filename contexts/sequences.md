---
description: >-
  Configure and execute a serie of actions or sending messages, based on an
  event that occurred in the conversation.
---

# Sequences

All the sequences that are needed can be created, in any context of the conversation. But only one will remain active per user at any given time.&#x20;

{% hint style="info" %}
Can be very useful when it comes to sending reminder messages in the development of a sales funnels for instance.
{% endhint %}

## Start a sequence

To start a sequence, the following method is used, which can be called within an [action block](blocks/) or in a callback in the [Conversation](../conversation.md) class:

### <mark style="color:orange;">`start_sequence(context_route=String)`</mark>

#### Start a sequence in the same context

```ruby
start_sequence "sign_up_sequence"
```

#### Stat a sequence in a different context

```ruby
start_sequence "profile/sign_up_sequence"
```

## Executing actions

Sequences are defined within the <mark style="color:red;">`sequences()`</mark> method of a [`Context`](./) class by calling the following method:

#### <mark style="color:orange;">`sequence(sequence_name=String|Symbol, &block)`</mark>

In turn, this will receive as parameters the name of the sequence and a block with one or several calls to the <mark style="color:orange;">`past()`</mark> method, one for each action of the sequence.

#### <mark style="color:orange;">`past(time_elapsed=ActiveSupport::Duration, &block)`</mark>

This last method will execute the code in the `block` argument, when the time defined in the `time_elapsed` argument has elapsed since the start of the sequence.

```ruby
def sequences

  sequence :sign_up_sequence do
      
    past 20.minutes do
      logger.debug "This will executed 20 minutes after secuence_start(:sign_up_sequence) was called"
    end
    
    past 3.hours do
      logger.debug "This will executed 3 hours after secuence_start(:sign_up_sequence) was called"
    end 
    
    past 2.days do
      logger.debug "You've already got the idea ;)"
    end

  end

end
```

## Stop a sequence

It will stop automatically after the execution of the last block in the sequence, but if it's necessary to stop it prematurely, the following method can be called:

#### <mark style="color:orange;">`stop_sequence(sequence_name=String|Symbol)`</mark>

## Full Example

The example below will attempt to get the user to complete the registration process by sending two reminders: one at `20 minutes` and one at `3 hours`.

In case the user does the registration process, we will stop the sequence prematurely.

```ruby
class MainContext < Conversation

  def blocks

    intent :greeting do 
      @reply.text "Hello!"
      @rsp.quick_reply(
        "To start, please create an account",
        [
          {
            title: "Continue",
            payload: "sign_up"
          }
        ]
      )
      start_sequence :sign_up_sequence
    end
    
    postback :sign_up do 
      @reply.text "To create a new account please click in the button bellow."
      @reply.url(
        {
          title: "Create a new User",
          url: "https://kogno.io/sign_up"
        }
      )

      stop_sequence :sign_up_sequence
      
    end

  end
  
  def sequences
  
    sequence :sign_up_sequence do
    
      past 20.minutes do
        @rsp.quick_reply(
          "Don't forget to create your account.",
          [
            {
              title: "Create an Account",
              payload: "sign_up"
            }
          ]
        )
      end

      past 3.hours do
        @rsp.text "Did you know that by creatig an account with us you'll receive a gift?"
        @rsp.quick_reply(
          "Don't miss this oportunity",
          [
            {
              title: "Sign Up",
              payload: "sign_up"
            }
          ]
        )
      end
      
    end
    
  end
  
end
```

## Sequence daemon

This functionality has a independent process that must be running by calling the following commands in terminal:

### Foreground

```ruby
kogno sequences fg
```

### Background

```bash
kogno sequences start
```

#### With other Kogno's processes

It can also be started  with the other Kongo daemons like `http` and `schedule_messages` by running:

```
kogno start
```

#### Logs

See the logs in `logs/sequences.log`.

## Configuration

It could be the case when after the activation of a sequence, a user continues the conversation with the app and in between, receives a programmed message from an active sequence.

To avoid this problem, define the minimum time elapsed since the last message from the user, that the sequence must wait in order to execute the next block, by modifying the configuration file [`config/application.rb`](../getting-started/configuration.md).

```ruby
config.sequences.time_elapsed_after_last_usage = 900 # 15 minutes
```
