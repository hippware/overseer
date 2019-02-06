defmodule Overseer.Client do
  alias Overseer.Query

  use CommonGraphQLClient.Client,
    otp_app: :overseer,
    mod: Overseer.WockyApi

  defp handle(:get, :auth, token) do
    do_post(
      :authenticate,
      nil,
      Query.Auth.auth(),
      %{token: token}
    )
  end
end
