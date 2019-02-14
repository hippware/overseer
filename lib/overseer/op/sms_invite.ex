defmodule Overseer.Op.SMSInvite do
  require Logger

  alias Overseer.{TwilioWebhook, Utils, WockyApi}

  def run do
    TwilioWebhook.start_webhook_listener()

    Logger.info("Authenticating...")
    Utils.authenticate()

    Logger.info("Sending bulk invitation request...")
    target_number = Confex.get_env(:overseer, :sms_recipient)
    {:ok, data} = WockyApi.get(:bulk_invitation, [target_number])

    %{
      "result" => [
        %{
          "error" => nil,
          "phoneNumber" => ^target_number,
          "result" => "EXTERNAL_INVITATION_SENT",
          "user" => nil
        }
      ],
      "successful" => true
    } = data

    receive do
      {:sms_received, body} ->
        true = body =~ "has invited you to tinyrobot. Please visit https://"
        :ok
    after
      30_000 -> throw(:sms_not_received)
    end

    Logger.info("Test complete")
    :ok
  end
end
