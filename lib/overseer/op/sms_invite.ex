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
      after 30_000 -> throw(:sms_not_received)
    end

    Logger.info("Test complete")
    :ok
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

    # Give the ELBs time to pick up the server
    Process.sleep(30_000)
  end

  def init(req, state) do
    req = :cowboy_req.reply(200, req)
    Logger.info "Got request #{inspect req}"

    {:ok, body, req} = :cowboy_req.read_body(req)
    Logger.info "Got body #{inspect body}"

    send(state, :sms_received)
    {:ok, req, state}
  end
end
