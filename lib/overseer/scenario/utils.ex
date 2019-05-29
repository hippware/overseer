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

    u = get_last(session!).payload.response.data.authenticate.user

    if u do
      session!
      |> assign(user_id: u.id)
      |> aws_send(Auth.mark_transient())
      |> aws_recv()
    else
      session!
      |> log_error("No user returned: #{inspect(get_last(session!))}")
      |> error("No user")
    end
  end
end
