defmodule Overseer.LoadTest.LocationUpload do
  @moduledoc "Config for LocationUpload test"

  use Chaperon.LoadTest

  defdelegate default_config, to: Overseer.LoadTest.CommonConfig

  def scenarios,
    do: [
      {{1, Overseer.Scenario.LocationUpload},
       %{
         location_upload: %{
           register_batch: 40,
           users: 400,
           locations: 50
         }
       }}
    ]
end
