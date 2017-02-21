defmodule Simplebot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(Registry, [:unique, Registry.TelegramChat]),
      supervisor(Simplebot.Otp.TelegramChatSup, []),
      worker(Simplebot.Otp.TelegramClientWorker, []),
    ]
    opts = [strategy: :one_for_one, name: Simplebot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end