defmodule Egon.Redis.Dataset do
  @moduledoc false
  def purge(dataset_id) do
    Redix.command!(:redix, ["GET", "*#{dataset_id}*"])
    |> Enum.map(fn key -> Redix.command!(:redix, ["DEL", key]) end)
  end
end
