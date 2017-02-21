defmodule Simplebot.Telegram.TelegramBotUpdate do

  @moduledoc """
  Functions to retrieve data from Telegram Bot API updates
  """

  @doc """
  Returns {:ok, update_id, chat_id} from Telegram udpate
  """
  def get_update_data(%{"message" => %{"chat" => %{"id" => chat_id}}, "update_id" => update_id}) do
    {:ok, update_id, chat_id}
  end
end