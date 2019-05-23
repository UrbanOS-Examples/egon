defmodule Egon.Kafka.Pressurizer do
  @moduledoc false

  @doc """

  """
  def pressurize(dataset, topic, chunk_size, chunk_limit \\ 1) do
    Stream.repeatedly(fn -> Egon.Data.Generator.generate(dataset.technical.schema) end)
    |> Stream.map(fn message ->
      SmartCity.TestDataGenerator.create_data(%{dataset_id: dataset.id, payload: message})
    end)
    |> Stream.map(&add_key/1)
    |> Stream.chunk(chunk_size)
    |> Stream.map(fn messages -> Kaffe.Producer.produce_sync(topic, messages) end)
    |> Enum.take(chunk_limit)
  end

  defp gen_key() do
    :rand.uniform(1_000_000_000_000) |> to_string()
  end

  defp add_key(message) do
    {gen_key(), Jason.encode!(message)}
  end

  defp parallel_map(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
