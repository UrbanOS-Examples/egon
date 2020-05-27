use Mix.Config

config :prestige,
  headers: [
    user: "egon",
    catalog: "hive",
    schema: "default"
  ],
  log_level: :info

host =
  case System.get_env("HOST_IP") do
    nil -> "127.0.0.1"
    defined -> defined
  end

System.put_env("HOST", host)

endpoint = [{to_charlist(host), 9092}]

config :egon,
  divo: [
    {DivoKafka,
     [
       create_topics: "streaming-raw:1:1,streaming-validated:1:1,dead-letters:1:1",
       outside_host: host
     ]},
    DivoRedis
  ],
  divo_wait: [dwell: 500, max_tries: 240]

config :egon,
  kafka_endpoints: endpoint

config :redix,
  host: host

config :smart_city_registry,
  redis: [
    host: host
  ]

config :kaffe,
  producer: [
    topics: ["streaming-raw"],
    endpoints: endpoint
  ]
