defmodule Simplebot.Otp.TelegramChatSup do
  use Supervisor
  require Logger

  alias Simplebot.Otp.TelegramChatWorker

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: Simplebot.Otp.TelegramChatSup)
  end

  def init(_args) do
    children = [
      worker(TelegramChatWorker, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
