defmodule Overseer.Utils do
  alias Overseer.{JWT, WockyApi}

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

  def authenticate do
    {:ok, %{"user" => %{"id" => id}}} = WockyApi.get(:auth, jwt())
    id
  end
end
