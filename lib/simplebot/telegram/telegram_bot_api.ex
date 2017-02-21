defmodule Simplebot.Telegram.TelegramBotApi do

  @moduledoc """
  Telegram API methods - https://core.telegram.org/bots/api/#available-methods
  """

  require Logger
  @telegram_bot_api_url "https://api.telegram.org"


  ##
  ## API
  ##

  @doc """
  Telegram API - getUpdates: https://core.telegram.org/bots/api/#getupdates
  """
  def get_updates!(token, offset \\ 0, api_timeout_ms \\ 5_000, limit \\ 100) do
    timeout_secs = round(api_timeout_ms / 1_000)
    params = %{
      offset: offset,
      limit: limit,
      timeout: timeout_secs
    }
    json_request = Poison.encode!(params)
    request_timeout_ms = round(timeout_secs * 1.2 * 1_000)
    Logger.debug "getUpdates - request: #{inspect params}"
    result = HTTPotion.post("#{bot_url(token)}/getUpdates", [body: json_request,
      headers: ["Content-Type": "application/json"], timeout: request_timeout_ms])
    case result do
      %HTTPotion.Response{body: response_body, status_code: 200} ->
        %{"ok" => true, "result" => results} = Poison.decode!(response_body)
        Logger.debug "getUpdates - response: #{inspect results}"
        results
      %HTTPotion.ErrorResponse{message: "req_timedout"} ->
        []
    end
  end

  @doc """
  Telegram API - send_message: https://core.telegram.org/bots/api/#sendmessage
  """
  def send_message(token, chat_id, message, parse_mode \\ "Markdown", reply_to_message_id \\ nil) do
    request = Map.merge(message, %{
      "chat_id" => chat_id,
      "parse_mode" => parse_mode
    })
    request2 = case reply_to_message_id do
      nil -> request
      value -> Map.put(request, :reply_to_message_id, value)
    end
    json_request = Poison.encode!(request2)
    result = HTTPotion.post("#{bot_url(token)}/sendMessage", [body: json_request,
      headers: ["Content-Type": "application/json"]])
    %HTTPotion.Response{body: response_body, status_code: 200} = result
    {:ok, Poison.decode!(response_body)}
  end


  ##
  ## Private functions
  ##

  defp bot_url(token), do: "#{@telegram_bot_api_url}/bot#{token}"
end