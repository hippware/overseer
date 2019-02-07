defmodule Overseer.MixProject do
  use Mix.Project

  def project do
    [
      version: version(),
      elixir: "~> 1.7",
      app: :overseer,
      start_permanent: false,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp version do
    {ver_result, _} = System.cmd("elixir", ["version.exs"])
    ver_result
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Overseer, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      #{:absinthe_websocket, "~> 0.2.0"},
      {:absinthe_websocket, path: "/home/bernard/src/absinthe_websocket", override: true},

      #{:common_graphql_client, "~> 0.3.0"},
      {:common_graphql_client, path: "/home/bernard/src/common_graphql_client"},

      {:confex, "~> 3.4"},
      {:guardian, "~> 1.2.1"},
      {:httpoison, "~> 1.1"},
      {:json_web_token, "~> 0.2.10"},
      {:mogrify, "~> 0.7.0"},

      {:distillery, "~> 2.0", runtime: false},
    ]
  end

  defp aliases do
    [
      recompile: ["clean", "compile"],
      prepare: ["deps.get", "recompile"],
    ]
  end
end
