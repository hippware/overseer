# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :overseer,
  jwt_key: {:system, :string, "OVERSEER_JWT_KEY"},
  pagerduty_key: {:system, :string, "OVERSEER_PAGERDUTY_KEY"},
  pagerduty_service:
    {:system, :string, "OVERSEER_PAGERDUTY_SERVICE", "PB5DTCR"},
  pagerduty_user:
    {:system, :string, "OVERSEER_PAGERDUTY_USER", "bernard@hippware.com"},
  enable_pagerduty: false

config :overseer, Overseer.WockyApi,
  client: Overseer.Client,
  query_caller: CommonGraphQLClient.Caller.WebSocket,
  subscription_caller: CommonGraphQLClient.Caller.WebSocket,
  websocket_api_url: "wss://testing.dev.tinyrobot.com/graphql/websocket"

import_config "#{Mix.env()}.exs"
