defmodule Overseer.Query.Auth do
  def auth do
    """
    mutation ($token: String!) {
      authenticate (input: {token: $token}) {
        user {
          id
        }
      }
    }
    """
  end
end
