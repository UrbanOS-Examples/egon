# Egon

Egon is an elixir app that has little actual code. Its main purpose is to be used as a remote elixir console inside a Kubernetes cluster. It includes libraries for interacting with Kafka, Presto, and Redis. It also provides an easy place to add helper methods to be used in debugging the cluster.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `egon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:egon, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/egon](https://hexdocs.pm/egon).
