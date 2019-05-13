defmodule Overseer.Scenario.SMSInvite do
  @moduledoc "Test scenario for Twilio-based SMS invitations"

  use Overseer.Chaperon.Scenario

  alias Overseer.Query.BulkUser
  alias Overseer.Scenario.Utils
  alias Overseer.TwilioWebhook

  def init(session), do: {:ok, session}

  def run(session!) do
    TwilioWebhook.start_webhook_listener()

    target_number = Confex.get_env(:overseer, :sms_recipient)

    session! =
      session!
      |> log_info("Authenticating...")
      |> Utils.authenticate()
      |> log_info("Sending bulk invitation request...")
      |> aws_send(BulkUser.bulk_invitation([target_number]))
      |> aws_recv()

    %{
      result: [
        %{
          error: nil,
          phoneNumber: ^target_number,
          result: "EXTERNAL_INVITATION_SENT",
          user: nil
        }
      ],
      successful: true
    } = get_last(session!)

    receive do
      {:sms_received, body} ->
        true = body =~ "has invited you to tinyrobot. Please visit https://"
        :ok
    after
      60_000 -> throw(:sms_not_received)
    end

    log_info(session!, "Test complete")
  end
end
