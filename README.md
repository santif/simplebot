# Simplebot

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

3. Chat with SimpleBot
