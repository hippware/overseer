defmodule Overseer.Utils do
  alias Overseer.JWT
  alias Overseer.Query.Auth

  use Overseer.Chaperon.Scenario

  def jwt do
    phone_number = "+15556667777"

    claims = %{
      typ: "bypass",
      dvc: "overseer",
      phone_number: phone_number,
      aud: "Wocky"
    }

    {:ok, token, _} = JWT.encode_and_sign(phone_number, claims)
    token
  end

  def authenticate(session) do
    session
    |> log_info("Connecting")
    |> aws_connect(Confex.get_env(:overseer, :websocket_path, "/"))
    |> log_info("Sending auth")
    |> aws_send(Auth.auth(jwt()))
    |> aws_recv()
  end
end
