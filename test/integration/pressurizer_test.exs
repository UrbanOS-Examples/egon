defmodule PressurizerTest do
  use ExUnit.Case
  use Divo
  @dataset_id "12345"
  @endpoint Application.get_env(:kaffe, :producer)[:endpoints]

  import Record, only: [defrecord: 2, extract: 2]

  defrecord :kafka_message,
            extract(:kafka_message, from_lib: "kafka_protocol/include/kpro_public.hrl")

  setup_all do
    {:ok, _} =
      %{id: "12345"}
      |> SmartCity.TestDataGenerator.create_dataset()
      |> SmartCity.Dataset.write()

    :ok
  end

  test "egon produces a small amount of data to a topic" do
    dataset_id = @dataset_id

    dataset_id
    |> SmartCity.Dataset.get!()
    |> Egon.Kafka.Pressurizer.pressurize("streaming-raw", 5, 5)

    assert number_of_messages("streaming-raw", 5)
  end

  test "egon produces a medium amount of data to a topic" do
    dataset_id = @dataset_id

    dataset_id
    |> SmartCity.Dataset.get!()
    |> Egon.Kafka.Pressurizer.pressurize("streaming-validated", 100, 10)

    assert number_of_messages("streaming-validated", 100)
  end

  defp number_of_messages(topic, number_expected) do
    :ok ==
      Patiently.wait_for!(
        fn ->
          message_count =
            topic
            |> fetch_and_unwrap()
            |> Enum.count()

          message_count == number_expected
        end,
        dwell: 2000,
        max_tries: 10
      )
  end

  defp fetch_and_unwrap(topic) do
    {:ok, {_, messages}} = :brod.fetch(@endpoint, topic, 0, 0)
    {:ok, {_, messages2}} = :brod.fetch(@endpoint, topic, 0, Enum.count(messages))

    messages = messages ++ messages2

    messages
    |> Enum.map(fn message ->
      kafka_message(message, :value)
    end)
    |> Enum.map(fn body -> Jason.decode!(body, keys: :atoms) end)
  end
end
