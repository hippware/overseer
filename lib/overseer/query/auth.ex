defmodule Overseer.Query.Auth do
  @moduledoc "Auth-related GraphQL queries"

  def auth(token) do
    {
      """
      mutation ($token: String!) {
        authenticate (input: {token: $token}) {
          user {
            id
          }
        }
      }
      """,
      %{token: token}
    }
  end

  def mark_transient do
    {
      """
      mutation {
        userUpdate (input: {values: {transient: true}}) {
          successful
        }
      }
      """,
      %{}
    }
  end
end
