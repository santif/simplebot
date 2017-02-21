defmodule Simplebot.Otp.TelegramChatWorker do
  use GenServer
  require Logger

  alias Simplebot.Otp.TelegramChatWorker.State
  alias Simplebot.Otp.TelegramChatSup
  alias Simplebot.Bot.SimpleBot
  alias Simplebot.Telegram.TelegramBotApi
  alias Simplebot.Telegram.TelegramBotUpdate

  defmodule State do
    defstruct chat_id: nil,
      chat_state: nil,
      bot_token: nil
  end


  ##
  ## API
  ##

  def start_link(chat_id) do
    via_tuple = {:via, Registry, {Registry.TelegramChat, chat_id}}
    GenServer.start_link(__MODULE__, [chat_id], name: via_tuple)
  end

  def apply_update(update) do
    {:ok, update_id, chat_id} = TelegramBotUpdate.get_update_data(update)
    server = get_or_create_chat_server(chat_id)
    GenServer.cast(server, {:update, update})
    {:ok, update_id}
  end


  ##
  ## GenServer callbacks
  ##

  def init([chat_id]) do
    Logger.debug "Starting TelegramChatWorker - chat_id: #{chat_id}"
    bot_token = Application.get_env(:simplebot, :telegram_bot_token)
    {:ok, chat_state} = SimpleBot.init()
    {:ok, %State{chat_id: chat_id, chat_state: chat_state, bot_token: bot_token}}
  end

  def handle_cast({:update, %{"message" => message}}, state = %State{
      chat_state: chat_state, bot_token: bot_token, chat_id: chat_id}) do
    case SimpleBot.handle_message(message, chat_state) do

      {:reply, reply, new_chat_state} ->
        ## TODO view module
        {:ok, _message_sent} = TelegramBotApi.send_message(bot_token, chat_id, reply, "Markdown")
        {:noreply, %State{state | chat_state: new_chat_state}}

      {:noreply, new_chat_state} ->
        {:noreply, %State{state | chat_state: new_chat_state}}
    end
  end


  ##
  ## Private functions
  ##

  defp get_or_create_chat_server(chat_id) do
    case Registry.lookup(Registry.TelegramChat, chat_id) do
      [] ->
        {:ok, pid} = Supervisor.start_child(TelegramChatSup, [chat_id])
        pid
      [{pid, nil}] ->
        pid
    end
  end
end