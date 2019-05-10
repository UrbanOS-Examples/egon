defmodule Egon.Redis.Dataset do
  def purge(dataset_id) do
    Redix.command!(:redix, ["GET", "*#{dataset_id}*"])
    |> Enum.map(fn key -> Redix.command!(:redix, ["DEL", key]) end)
  end
end
