# Simplebot

Insanely overarchitected Telegram Bot example, written in Elixir.


## Instructions

1. Create new file `config/dev_secret.exs` with the following content:

```
use Mix.Config

config :simplebot,
  telegram_bot_token: "...TOKEN..."
```

2. Compile and run application:

```
$ mix deps.get
$ mix compile
$ iex -S mix
```

3. Chat with SimpleBot:

`/echo` command switch to "echo mode". Next text will be processed by SimpleBot.
