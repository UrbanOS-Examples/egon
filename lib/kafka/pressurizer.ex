defmodule Egon.Kafka.Pressurizer do
  @moduledoc false

  @doc """
  Pressurize takes a full SmartCity dataset, a name of a topic, a number of messages to send, and an optional chunk size to produce them in.
  """
  def pressurize(dataset, topic, message_count, chunk_size \\ 100) do
    1..message_count
    |> Stream.take(message_count)
    |> Stream.map(fn _ -> Egon.Data.Generator.generate(dataset.technical.schema) end)
    |> Stream.map(fn message ->
      SmartCity.TestDataGenerator.create_data(%{dataset_id: dataset.id, payload: message})
    end)
    |> Stream.map(&add_key/1)
    |> Stream.chunk(chunk_size)
    |> Stream.map(fn messages -> Kaffe.Producer.produce_sync(topic, messages) end)
    |> Enum.map(fn return -> return end)
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
