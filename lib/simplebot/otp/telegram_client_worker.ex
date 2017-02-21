defmodule Simplebot.Otp.TelegramClientWorker do
  use GenServer
  require Logger

  alias Simplebot.Telegram.TelegramBotApi
  alias Simplebot.Otp.TelegramClientWorker.State
  alias Simplebot.Otp.TelegramChatWorker

  defmodule State do
    defstruct bot_token: nil,
      last_update_id: 0
  end

  @default_interval 500
  @default_timeout 10_000
  @default_limit 100


  ##
  ## API
  ##

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end


  ##
  ## GenServer callbacks
  ##

  def init(_args) do
    send(self(), :check_for_updates)
    bot_token = Application.get_env(:simplebot, :telegram_bot_token)
    {:ok, %State{bot_token: bot_token, last_update_id: 0}}
  end

  def handle_info(:check_for_updates, state = %State{bot_token: bot_token,
      last_update_id: last_update_id}) do
    # Get updates
    timeout = Application.get_env(:simplebot, :get_updates_timeout, @default_timeout)
    limit = Application.get_env(:simplebot, :get_updates_limit, @default_limit)
    {:ok, updates, new_last_update_id} = retrieve_updates(bot_token, last_update_id, timeout, limit)

    # Check again in `interval` ms
    interval = Application.get_env(:simplebot, :get_updates_interval, @default_interval)
    Process.send_after(self(), :check_for_updates, interval)

    {:noreply, %State{state | last_update_id: new_last_update_id + 1}}
  end

  def handle_info(msg, state) do
    Logger.warn "Unhandled message: #{inspect msg}"
    {:noreply, state}
  end


  ##
  ## Private functions
  ##

  defp retrieve_updates(token, last_update_id, timeout, limit) do
    updates = TelegramBotApi.get_updates!(token, last_update_id, timeout, limit)
    max_update_id = updates
    |> List.foldl(last_update_id, fn(update, acc) ->
      {:ok, update_id} = TelegramChatWorker.apply_update(update)
      max(acc, update_id)
    end)
    {:ok, updates, max_update_id}
  end
end