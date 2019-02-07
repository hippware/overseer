defmodule Overseer.JWT do
  use Guardian,
    otp_app: :overseer,
    issuer: "TinyRobot/0.0.0 (Wocky Tester)",
    secret_key: {Confex, :get_env, [:overseer, :jwt_key]}

  def subject_for_token(phone_number, _claims), do: {:ok, phone_number}
  def resource_from_claims(subject), do: {:ok, subject}
end
