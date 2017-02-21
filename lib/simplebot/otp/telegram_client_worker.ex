defmodule Simplebot.Otp.TelegramClientWorker do
  use GenServer
  require Logger

  alias Simplebot.Otp.TelegramClientWorker.State
  alias Simplebot.Otp.TelegramChatWorker
  alias Simplebot.Telegram

  defmodule State do
    defstruct bot_token: nil,
      last_update_id: 0
  end

  @default_interval 1_000
  @default_timeout 10_000


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
    updates = Telegram.get_updates!(bot_token, last_update_id)
    last_update_id = updates
    |> List.foldl(0, fn(update, acc) ->
      {:ok, update_id} = TelegramChatWorker.apply_update(update)
      max(acc, update_id)
    end)
    interval = Application.get_env(:simplebot, :get_updates_interval, @default_interval)
    Process.send_after(self(), :check_for_updates, interval)
    {:noreply, %State{state | last_update_id: last_update_id + 1}}
  end

  # def handle_info(msg, state) do
  #   Logger.warn "Unhandled info: #{inspect msg}"
  #   {:noreply, state}
  # end
end