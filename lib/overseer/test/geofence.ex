defmodule Overseer.LoadTest.Geofence do
  @moduledoc "Config for Geofence test"

  use Chaperon.LoadTest

  defdelegate default_config, to: Overseer.LoadTest.CommonConfig

  def scenarios,
    do: [
      {{1, Overseer.Scenario.Geofence},
       %{
         geofence: %{
           bots: 1000,
           friends: 50,
           locations: 100
         }
       }}
    ]
end
