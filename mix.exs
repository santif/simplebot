defmodule Simplebot.Mixfile do
  use Mix.Project

  def project do
    [app: :simplebot,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application() do
    [extra_applications: [:logger],
     mod: {Simplebot.Application, []},
     applications: [:httpotion, :poison]]
  end

  defp deps() do
    [{:httpotion, "~> 3.0.2"},
     {:poison, "~> 3.1"}]
  end
end
