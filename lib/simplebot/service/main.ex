defmodule Simplebot.Service.Main do

  @doc """
  Main function of whole application.
  """
  def reverse(text) when is_binary(text) do
    {:ok, String.reverse(text)}
  end
end