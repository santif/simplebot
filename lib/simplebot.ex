defmodule Simplebot do

  def start() do
    Application.ensure_all_started(:simplebot)
  end
end