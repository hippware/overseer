# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :overseer,
  jwt_key:
    {:system, :string, "OVERSEER_JWT_KEY",
     "CgKG3D0OfVBMh3JiJfQGkS0SyTrBaaGfrl1MozWnjesSuhVLnMTHDwyXDC/f2dtu"},
  pagerduty_key: {:system, :string, "OVERSEER_PAGERDUTY_KEY"},
  pagerduty_service:
    {:system, :string, "OVERSEER_PAGERDUTY_SERVICE", "PB5DTCR"},
  pagerduty_user:
    {:system, :string, "OVERSEER_PAGERDUTY_USER", "bernard@hippware.com"},
  enable_pagerduty: false,
  sms_recipient: "+13076962511",
  twilio_auth_token: {:system, :string, "OVERSEER_TWILIO_AUTH_TOKEN"},
  webhook_url: "https://overseer.dev.tinyrobot.com/sms",
  websocket_base_url: "wss://staging.dev.tinyrobot.com/",
  # websocket_base_url: "wss://testing.dev.tinyrobot.com/",
  # websocket_base_url: "ws://localhost:4000/",
  websocket_path: "graphql/websocket",
  number_prefix: "+1556"

config :logger,
  level: :debug

import_config "#{Mix.env()}.exs"
