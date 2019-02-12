defmodule Overseer.Op.SMSInvite do
  require Logger

  alias ExTwilio.RequestValidator
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
    after
      30_000 -> throw(:sms_not_received)
    end

    Logger.info("Test complete")
    :ok
  end

  ### Webhook listener
  def start_webhook_listener() do
    dispatch =
      :cowboy_router.compile([
        {:_, [{"/sms", __MODULE__, self()}]}
      ])

    {:ok, _} =
      :cowboy.start_clear(
        :sms_webhook_listener,
        [{:port, 8080}],
        %{env: %{dispatch: dispatch}}
      )

    # Give the ELBs time to pick up the server
    Process.sleep(30_000)
  end

  def init(req, state) do
    Logger.info("Validating request...")

    {:ok, params, req} = :cowboy_req.read_urlencoded_body(req)
    params = Enum.into(params, %{})
    Logger.info("Got params: #{inspect params}")

    signature = :cowboy_req.header("x-twilio-signature", req)
    Logger.info("Got signature: #{inspect signature}")
    url = Confex.get_env(:overseer, :webhook_url)
    Logger.info("Got url: #{inspect url}")
    auth_token = Confex.get_env(:overseer, :twilio_auth_token)
    Logger.info("Auth token is_nil: #{is_nil(auth_token)}")

    req =
      if RequestValidator.valid?(url, params, signature, auth_token) do
        Logger.info("Got SMS body: #{params["Body"]}")

        send(state, :sms_received)
        :cowboy_req.reply(200, req)
      else
        Logger.info("Ignoring invalid request: #{inspect(req)}")
        req
      end

    {:ok, req, state}
  end
end
