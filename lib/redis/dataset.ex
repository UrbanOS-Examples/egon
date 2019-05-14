defmodule Egon.Redis.Dataset do
  @moduledoc false
  def purge(dataset_id, limit \\ 10) do
    keys = Redix.command!(:redix, ["KEYS", "*#{dataset_id}*"])

    if length(keys) <= limit do
      keys
      |> Enum.map(fn key -> Redix.command!(:redix, ["DEL", key]) end)
    else
      raise "Tried to delete #{length(keys)} keys from redis when the limit specified is #{limit}. Did you mean to wipe out this much of Redis?"
    end
  end
end
