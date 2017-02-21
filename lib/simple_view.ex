defmodule Simplebot.SimpleView do

  def render(_reply = %{text: text}) do
    {:ok, text, "Markdown"}
  end
end