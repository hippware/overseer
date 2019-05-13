defmodule Overseer.Scenario.Utils do
  @moduledoc "Helper functions for test scenarios"

  alias Overseer.{JWT, NumberBroker}
  alias Overseer.Query.Auth

  use Overseer.Chaperon.Scenario

  def jwt do
    phone_number = NumberBroker.get()

    claims = %{
      typ: "bypass",
      dvc: "overseer",
      phone_number: phone_number,
      aud: "Wocky"
    }

    {:ok, token, _} = JWT.encode_and_sign(phone_number, claims)
    token
  end

  def authenticate(session!) do
    session! =
      session!
      |> log_info("Connecting")
      |> aws_connect(Confex.get_env(:overseer, :websocket_path, "/"))
      |> log_info("Sending auth")
      |> aws_send(Auth.auth(jwt()))
      |> aws_recv()

    session!
    |> assign(
      user_id: get_last(session!).payload.response.data.authenticate.user.id
    )
    |> aws_send(Auth.mark_transient())
    |> aws_recv()
  end
end
