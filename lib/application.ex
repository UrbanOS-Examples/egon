defmodule Egon.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        redis()
      ]
      |> List.flatten()

    opts = [strategy: :one_for_one, name: Egon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp redis do
    Application.get_env(:redix, :host)
    |> case do
      nil -> []
      host -> {Redix, host: host, name: :redix}
    end
  end
end
