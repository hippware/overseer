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
      # TODO: Back to upstream when changes are merged
      {:chaperon, github: "hippware/chaperon", branch: "working"},
      {:confex, "~> 3.4"},
      {:cowboy, "~> 2.6"},
      {:ex_twilio, "~> 0.7.0"},
      {:faker, "~> 0.12"},
      {:guardian, "~> 2.0.0"},
      {:httpoison, "~> 1.5", override: true},
      {:json_web_token, "~> 0.2.10"},
      {:mixduty, "~> 0.1.0"},
      {:mogrify, "~> 0.7.0"},
      {:rexbug, ">= 1.0.0"},
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
