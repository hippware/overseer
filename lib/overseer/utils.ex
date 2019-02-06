defmodule Overseer.Utils do
  alias Overseer.JWT

  def create_user do
    :ok

  end

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
end
