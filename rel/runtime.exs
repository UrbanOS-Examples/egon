use Mix.Config

required_envars = ["REDIS_HOST", "KAFKA_BROKERS"]

Enum.each(required_envars, fn var ->
  if is_nil(System.get_env(var)) do
    raise ArgumentError, message: "Required environment variable #{var} is undefined"
  end
end)

kafka_brokers = System.get_env("KAFKA_BROKERS")
redis_host = System.get_env("REDIS_HOST")

endpoints =
  kafka_brokers
  |> String.split(",")
  |> Enum.map(&String.trim/1)
  |> Enum.map(fn entry -> String.split(entry, ":") end)
  |> Enum.map(fn [host, port] -> {String.to_atom(host), String.to_integer(port)} end)

config :smart_city_registry,
  redis: [
    host: redis_host
  ]

config :redix,
  host: redis_host

config :kaffe,
  producer: [
    topics: ["streaming-dead-letters"],
    endpoints: endpoints
  ]
