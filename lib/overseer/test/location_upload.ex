defmodule Overseer.LoadTest.LocationUpload do
  @moduledoc "Config for LocationUpload test"

  use Chaperon.LoadTest

  defdelegate default_config, to: Overseer.LoadTest.CommonConfig

  def scenarios,
    do: [
      {{1, Overseer.Scenario.LocationUpload},
       %{
         location_upload: %{
           register_batch: 20,
           users: 5000,
           locations: 50
         }
       }}
    ]
end
