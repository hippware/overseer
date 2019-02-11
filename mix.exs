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
      extra_applications: [:crypto, :inets, :logger],
      mod: {Overseer, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe_websocket,
       github: "hippware/absinthe_websocket",
       branch: "optional-async",
       override: true},
      {:common_graphql_client,
       github: "hippware/common_graphql_client", branch: "optional-async"},
      {:confex, "~> 3.4"},
      {:guardian, "~> 1.2.1"},
      {:httpoison, "~> 1.5"},
      {:json_web_token, "~> 0.2.10"},
      {:mixduty, "~> 0.1.0"},
      {:mogrify, "~> 0.7.0"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:distillery, "~> 2.0", runtime: false}
    ]
  end

  defp aliases do
    [
      recompile: ["clean", "compile"],
      prepare: ["deps.get", "recompile"]
    ]
  end
end
