defmodule Overseer.Query.Bot do
  @moduledoc "Bot-related GraphQL queries"

  def create(title, lat, lon) do
    {
      """
      mutation ($title: String!, $lat: Float!, $lon: Float!) {
        botCreate (input: {values: {title: $title, lat: $lat, lon: $lon}}) {
          result {
            id
          }
        }
      }
      """,
      %{title: title, lat: lat, lon: lon}
    }
  end
end
