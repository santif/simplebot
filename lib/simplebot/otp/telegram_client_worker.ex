defmodule Simplebot.Otp.TelegramClientWorker do
  use GenServer
  require Logger

  alias Simplebot.Telegram.TelegramBotApi
  alias Simplebot.Otp.TelegramClientWorker.State
  alias Simplebot.Otp.TelegramChatWorker

  defmodule State do
    defstruct bot_token: nil,
      offset: -1
  end

  @default_interval 500
  @default_timeout 10_000
  @default_limit 100
  @default_offset 1

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
    {:ok, %State{bot_token: bot_token, offset: @default_offset}}
  end

  def handle_info(:check_for_updates, state = %State{bot_token: bot_token,
      offset: offset}) do
    # Get updates
    timeout = Application.get_env(:simplebot, :get_updates_timeout, @default_timeout)
    limit = Application.get_env(:simplebot, :get_updates_limit, @default_limit)
    {:ok, max_update_id} = retrieve_updates(bot_token, offset, timeout, limit)

    # Check again in `interval` ms
    interval = Application.get_env(:simplebot, :get_updates_interval, @default_interval)
    Process.send_after(self(), :check_for_updates, interval)

    {:noreply, %State{state | offset: max_update_id + 1}}
  end

  def handle_info(msg, state) do
    Logger.warn "Unhandled message: #{inspect msg}"
    {:noreply, state}
  end


  ##
  ## Private functions
  ##

  defp retrieve_updates(token, offset, timeout, limit) do
    updates = TelegramBotApi.get_updates!(token, offset, timeout, limit)
    last_update_id = updates
    |> List.foldl(offset, fn(update, _acc) ->
      {:ok, update_id} = TelegramChatWorker.apply_update(update)
      update_id
    end)
    {:ok, last_update_id}
  end
end
