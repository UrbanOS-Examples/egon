# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
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
  divo_wait: [dwell: 700, max_tries: 50]

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

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :egon, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:egon, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
