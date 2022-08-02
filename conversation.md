# Conversation Class

The `Conversation` class is located at `app/conversation.rb` file.

Every message that arrives and every reply sent can be handled and accessed via callbacks defined here and all the [Contexts](contexts/) should inherit this class.

{% hint style="info" %}
For those who are familiar with Ruby on Rails, this class is the equivalent to `ApplicationController`.
{% endhint %}

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

| Callback       | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| before\_blocks | This callback will be executed before the [<mark style="color:orange;">`blocks()`</mark>](contexts/#method-blocks) method from a Context class is called.                                                                                                                                                                                                                                                                                                                                                                          |
| after\_blocks  | This callback will be executed after the [<mark style="color:orange;">`blocks()`</mark>](contexts/#method-blocks) method from a Context class is called.                                                                                                                                                                                                                                                                                                                                                                           |
| before\_exit   | <p>This callback will be executed before the conversation context is changed.<br><br>Specifically in the call of methods <a href="contexts/#moving-between-contexts"><mark style="color:orange;"><code>change_to()</code></mark> or <mark style="color:orange;"><code>context_exit()</code></mark></a>. </p><p></p><p>In this callback, the method <a href="contexts/blocks/#halt"><mark style="color:orange;"><code>halt()</code></mark></a> can be implemented, to prevent the conversation context finally changes or exit.</p> |

## Accessible Instances and methods

These instances and methods are accessible from the `Conversation` class and also from any [`Context` class](contexts/) defined in a project.

### <mark style="color:orange;">`@user`</mark>

It is an instance of the `User` model (`ActiveRecord::Base`) that corresponds to the user who sent the incoming message.

#### Usage

```ruby
class Conversation < Kogno::Context

  before_blocks :log_user_platform

  def log_user_platform
    logger.info "The user's platform is #{@user.platform}"
  end

end
```

### <mark style="color:orange;">`@message`</mark>

It is the instance of the user's incoming message.

#### Usage

* **To see the message content:** `@message.text`
* **Catch a button click event:** `@message.postback_payload` and if includes parameters `@message.postback_params`. Read more about [postbacks](contexts/blocks/postback.md).
* Check if the message is empty: `@message.empty?`

See the full list of methods here.

### <mark style="color:orange;">`@reply`</mark>

It is an instance of the `Kogno::Notification` class, which contains a wide variety of reply messages like text, button, url, carousel, etc. Full list [here](replies-notifications/#message-formats).

{% hint style="success" %}
In Kogno, we try to unify almost all reply types for all supported platforms, so that a single code can be written for all of them.
{% endhint %}

#### Usage

```ruby
class Conversation < Kogno::Context

  after_blocks :send_a_final_message

  def send_a_final_message
    @reply.text "I'll respond this mesage all the time."
  end


end
```

For more information and examples, check the [Replies section](replies-notifications/).

### Methods

Also methods like [<mark style="color:orange;">`change_to()`</mark>](contexts/#change\_to-route-string-params-hash), [<mark style="color:orange;">`delegate_to()`</mark>](contexts/#delegate\_to-route-string-args-hash) and [<mark style="color:orange;">`halt()`</mark>](contexts/blocks/#halt).
