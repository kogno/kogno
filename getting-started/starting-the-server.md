# Starting the Server

## Web Server

The web server will receive incoming updates via an outgoing webhook from the messaging platforms configured in a given project, such as [Messenger](messenger-configuration.md), [Telegram](telegram-configuration.md) or [WhatsApp](whatsapp-configuration.md).

It will run in the port configured in the field `config.http_port` located in the config file [`config/application.rb`](configuration.md)``

### Run in Foreground

For developing purposes and testing your server quickly, run this command:

```
kogno http fg
```

This will show all the outputs in foreground instead of sending them to logs file in `logs/http.log`.

{% hint style="info" %}
#### Tunnel to localhost using Ngrok

We recommend to download and use [Ngrok](https://ngrok.com/download) to create a local tunnel to your development machine.
{% endhint %}

### Run as Daemon

To run the web server in the background, simply run the command:

```bash
kogno http start
```

This will write all the outputs in the logs file located in `logs/http.log`.

#### Stop, Restart and Status

```
kogno http stop
```

```
kogno http restart
```

```
kogno http status
```

### Production web server

{% hint style="success" %}
Since all messaging platforms require secure callback urls and Kogno only supports the HTTP protocol.&#x20;

We suggest setting up an HTTPS Server in either Apache or Nginx and making a gateway to the Kogno web server http port.
{% endhint %}

## Other processes

There are other processes that, together with the web server, are part of the whole Kogno server, they can be controlled separately or together.

### Sequences Process

Sequences, is a functionality that allows to create a sequence of actions and/or messages, which will be executed on a scheduled basis from the occurrence of an event in the conversation.&#x20;

This process execute the expired actions in the sequences.

#### Run in Foreground

```
kogno sequences fg
```

#### Run as Daemon

```
kogno sequences start
```

Logs are available in `logs/sequences.log`

{% hint style="info" %}
`stop`, `restart` and `status` also available. Read more about this in [Sequences Chapter](../contexts/sequences.md).
{% endhint %}

### Scheduled Messages process.

This functionality allows to send a messages in the future and this process send the scheduled messages from the message queue located in the database table `kogno_scheduled_messages`.

#### Run in Foreground

```
kogno scheduled_messages fg
```

#### Run as Daemon

```
kogno scheduled_messages start
```

Logs are available in `logs/scheduled_messages.log`

{% hint style="info" %}
`stop`, `restart` and `status` also available. Learn more about this in [Scheduled Messages Chapter](../scheduled-messages.md).
{% endhint %}

## All Processes

All processes can be controlled at once using the following commands:

### Start

```
kogno start
```

#### Output

```
Kogno 1.0.1 server starting in production
Http: daemon started.
Sequence: daemon started.
Scheduled Messages: daemon started.
```

### Stop&#x20;

```
kogno stop
```

{% hint style="info" %}
`restart` and `status` also available. Learn more about this in [Command Line - Server](../command-line.md#all-daemons)
{% endhint %}
