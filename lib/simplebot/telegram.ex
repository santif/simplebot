defmodule Simplebot.Telegram do

  @moduledoc """
  TODO - document
  """

  require Logger

  @telegram_bot_api_url "https://api.telegram.org"

  @doc """
  TODO - document
  """
  def get_updates!(token, offset \\ 0, limit \\ 100, timeout \\ 5_000) do
    params = %{
      offset: offset,
      limit: limit,
      timeout: timeout}
    json_request = Poison.encode!(params)
    result = HTTPotion.post("#{bot_url(token)}/getUpdates", [body: json_request,
      headers: ["Content-Type": "application/json"]])
    case result do
      %HTTPotion.Response{body: response_body, status_code: 200} ->
        %{"ok" => true, "result" => results} = Poison.decode!(response_body)
        results
      %HTTPotion.ErrorResponse{message: "req_timedout"} ->
        []
    end
  end

  @doc """
  TODO - document
  """
  def send_message(token, chat_id, text, parse_mode \\ "Markdown", reply_to_message_id \\ nil) do
    request = %{
      chat_id: chat_id,
      text: text,
      parse_mode: parse_mode,
    }
    request = case reply_to_message_id do
      nil -> request
      value -> Map.put(request, :reply_to_message_id, value)
    end
    json_request = Poison.encode!(request)
    result = HTTPotion.post("#{bot_url(token)}/sendMessage", [body: json_request,
      headers: ["Content-Type": "application/json"]])
    %HTTPotion.Response{body: response_body, status_code: 200} = result
    {:ok, Poison.decode!(response_body)}
  end

  @doc """
  Returns {:ok, update_id, chat_id} from Telegram udpate
  """
  def get_update_data(%{"message" => %{"chat" => %{"id" => chat_id}}, "update_id" => update_id}) do
    {:ok, update_id, chat_id}
  end

  @doc """
  Parse incoming update
  """
  def parse_update(%{"message" => %{"text" => text}}) do
    %{text: text}
  end


  ##
  ## Private functions
  ##

  defp bot_url(token), do: "#{@telegram_bot_api_url}/bot#{token}"
end