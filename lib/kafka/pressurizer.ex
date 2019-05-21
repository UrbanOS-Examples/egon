defmodule Egon.Kafka.Pressurizer do
  def pressurize(dataset, topic, messages, chunk \\ 1) do
    Stream.repeatedly(fn -> Egon.Data.Generator.generate(dataset.technical.schema) end)
    |> Stream.map(fn message ->
      SmartCity.TestDataGenerator.create_data(%{dataset_id: dataset.id, payload: message})
    end)
    |> Stream.map(&add_key/1)
    |> Stream.chunk_every(chunk)
    |> Enum.take(messages)
    |> pmap(fn messages -> Kaffe.Producer.produce_sync(topic, messages) end)
  end

  # gen_key = fn -> :rand.uniform(1_000_000_000_000) |> to_string() end

  defp gen_key() do
    :rand.uniform(1_000_000_000_000) |> to_string()
  end

  defp add_key(message) do
    {gen_key(), Jason.encode!(message)}
  end

  defp pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
