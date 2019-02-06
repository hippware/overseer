# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :overseer,
  jwt_key: {:system, :string, "OVERSEER_JWT_KEY"}

config :overseer, Overseer.WockyApi,
  client: Overseer.Client,
  query_caller: CommonGraphQLClient.Caller.Http,
  http_api_url: "https://testing.dev.tinyrobot.com/graphql"
