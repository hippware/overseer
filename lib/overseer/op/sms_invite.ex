defmodule Overseer.Op.SMSInvite do
  require Logger

  alias Overseer.{Utils, WockyApi}

  def run do
    Logger.info("Starting webhook listener...")
    start_webhook_listener()

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
      :sms_received -> :ok
      after 10_000 -> :sms_not_received
    end
  end

  ### Webhook listener
  def start_webhook_listener() do
    dispatch = :cowboy_router.compile([
      {:_, [{"/sms", __MODULE__, self()}]}
    ])
    {:ok, _} = :cowboy.start_clear(:sms_webhook_listener,
      [{:port, 8080}],
      %{env: %{dispatch: dispatch}}
    )
  end

  def init(req, state) do
    :cowboy_req.reply(200, req)
    Logger.info "Got request #{inspect req}"

    send(state, :sms_received)
    {:ok, req, state}
  end
end