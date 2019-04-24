defmodule Overseer.Query.User do
  @moduledoc "User-related GraphQL queries"

  def delete do
    {
      """
      mutation {
        userDelete {
          successful
        }
      }
      """,
      %{}
    }
  end

  def send_location(lat, lon, accuracy \\ 0.0) do
    {
      """
      mutation ($lat: Float!, $lon: Float!, $accuracy: Float!) {
        userLocationUpdate (input: {device: "overseer", lat: $lat, lon: $lon, accuracy: $accuracy}) {
          successful
        }
      }
      """,
      %{
        lat: lat,
        lon: lon,
        accuracy: accuracy
      }
    }
  end
end
