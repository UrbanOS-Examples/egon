defmodule PressurizerTest do
  use ExUnit.Case
  use Divo
  @dataset_id "12345"
  @endpoint Application.get_env(:kaffe, :producer)[:endpoints]

  setup_all do
    {:ok, dataset_id} =
      SmartCity.TestDataGenerator.create_dataset(%{id: "12345"})
      |> SmartCity.Dataset.write()

    :ok
  end

  test "egon produces to a topic" do
    dataset_id = @dataset_id

    dataset_id
    |> SmartCity.Dataset.get!()
    |> Egon.Kafka.Pressurizer.pressurize("streaming-raw", 5)

    assert any_messages_where("streaming-raw", fn message ->
             message.dataset_id == dataset_id
           end)
  end

  defp any_messages_where(topic, callback) do
    :ok ==
      Patiently.wait_for!(
        fn ->
          topic
          |> fetch_and_unwrap()
          |> Enum.any?(callback)
        end,
        dwell: 1000,
        max_tries: 10
      )
  end

  defp messages_as_expected(topic, expected, callback) do
    Patiently.wait_for!(
      fn ->
        actual =
          topic
          |> fetch_and_unwrap()
          |> Enum.map(callback)

        IO.puts("Waiting for actual #{inspect(actual)} to match expected #{inspect(expected)}")

        actual == expected
      end,
      dwell: 1000,
      max_tries: 10
    )
  end

  defp fetch_and_unwrap(topic) do
    {:ok, messages} = :brod.fetch(@endpoint, topic, 0, 0)

    messages
    |> Enum.map(fn {:kafka_message, _, _, _, key, body, _, _, _} ->
      {key, body}
    end)
    |> Enum.map(fn {_key, body} -> Jason.decode!(body, keys: :atoms) end)
  end
end
