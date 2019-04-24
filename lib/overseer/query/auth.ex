defmodule Overseer.Query.Auth do
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
end
