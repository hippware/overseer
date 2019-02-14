defmodule Overseer.TwilioWebhook do
  require Logger

  alias ExTwilio.RequestValidator

  def start_webhook_listener() do
    Logger.info("Starting webhook listener...")
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
    auth_token = Confex.get_env(:overseer, :twilio_auth_token)

    req =
      if RequestValidator.valid?(url, params, signature, auth_token) do
        Logger.info("Got SMS body: #{params["Body"]}")
        req = :cowboy_req.reply(204, req)

        send(state, {:sms_received, params["Body"]})
        req
      else
        Logger.info("Ignoring invalid request: #{inspect(req)}")
        req
      end

    {:ok, req, state}
  end
end
