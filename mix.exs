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

  def application do
    [
      extra_applications: [:logger],
      mod: {Egon.Application, []}
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:redix, "~> 0.9.3"},
      {:jason, "~>1.1"},
      {:tesla, "~> 1.2"},
      {:kaffe, "~> 1.13"},
      {:elsa, "~> 0.5.0"},
      {:smart_city_data, "~> 2.1"},
      {:smart_city_registry, "~> 3.3"},
      {:smart_city_test, "~> 0.3"},
      {:prestige, "~> 0.3"},
      {:divo, "~> 1.1", only: [:dev, :test, :integration]},
      {:divo_kafka, "~> 0.1", only: [:dev, :test, :integration]},
      {:divo_redis, "~> 0.1", only: [:dev, :integration]},
      {:credo, "~> 1.0", only: [:dev, :test, :integration], runtime: false}
    ]
  end
end
