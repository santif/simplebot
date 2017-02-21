defmodule Simplebot.Service.Echo do

  @doc """
  Echo text (reversed!)
  """
  def echo(text) when is_binary(text) do
    {:ok, String.reverse(text)}
  end
end