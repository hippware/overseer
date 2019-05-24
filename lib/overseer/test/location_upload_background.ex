defmodule Overseer.LoadTest.LocationUploadBackground do
  @moduledoc "Config for LocationUploadBackground test"

  use Chaperon.LoadTest

  defdelegate default_config, to: Overseer.LoadTest.CommonConfig

  def scenarios,
    do: [
      {{1, Overseer.Scenario.LocationUploadBackground},
       %{
         location_upload: %{
           register_batch: 20,
           users: 20,
           locations: 50
         }
       }}
    ]
end
