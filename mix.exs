defmodule Egon.MixProject do
  use Mix.Project

  def project do
    [
      app: :egon,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Egon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:redix, "~> 0.9.3"},
      {:jason, "~>1.1"},
      {:tesla, "~> 1.2"},
      {:kaffe, "~> 1.11"},
      {:smart_city_data, "~> 2.1"},
      {:smart_city_registry, "~> 2.6"},
      {:smart_city_test, "~> 0.2.0"},
      {:prestige, "~> 0.2.0", organization: "smartcolumbus_os"},
      {:divo, "~> 1.1", only: [:dev, :test, :integration]},
      {:divo_kafka, "~> 0.1", only: [:dev, :integration]},
      {:divo_redis, "~> 0.1", only: [:dev, :integration]},
      {:credo, "~> 1.0", only: [:dev, :test, :integration], runtime: false}
    ]
  end
end
