defmodule Overseer.Scenario.LocationUploadBackground do
  @moduledoc """
  Create a set of users and send repeated location updates from them
  """

  use Overseer.Chaperon.Scenario

  alias Chaperon.Session
  alias Faker.Address
  alias Overseer.Query.User
  alias Overseer.Scenario.Utils

  def init(session) do
    {:ok, session}
  end

  def run(session!) do
    batch_size = config(session!, [:location_upload, :register_batch])
    user_count = config(session!, [:location_upload, :users])
    batch_count = div(user_count, batch_size)

    session!
    |> set_timeout(:infinity)
    |> repeat(:async_batch, [batch_size], batch_count)
    |> log_warn("Users ready - sending GO")
    |> signal(:user, :go)
    |> await_all(:user)
  end

  def async_batch(session!, batch_size) do
    session!
    |> repeat({Session, :async}, [:run_user, [], :user], batch_size)
    |> repeat({Session, :await_signal}, [:user_ready], batch_size)
  end

  def run_user(session) do
    location_count = config(session, [:location_upload, :locations])

    session
    |> Utils.authenticate()
    # Pre-warm the location handler processes
    |> aws_send(User.send_location(Address.latitude(), Address.longitude()))
    |> aws_recv()
    |> signal_parent(:user_ready)
    |> call(:get_token)
    |> aws_close()
    |> update_config(
      base_url: fn _ -> Confex.get_env(:overseer, :rest_base_url) end
    )
    |> await_signal(:go)
    |> delay({:random, 120 |> seconds})
    |> repeat(:send_location, location_count)
  end

  def get_token(session!) do
    session! =
      session!
      |> aws_send(User.get_location_token())
      |> aws_recv()

    session!
    |> assign(
      location_token:
        get_last(session!).payload.response.data.userLocationGetToken.result
    )
  end

  def send_location(session) do
    session
    |> async(:send_location_http)
    |> delay(3 |> seconds)
    |> await(:send_location_http)
  end

  def send_location_http(session) do
    opts = [
      json: location_body(),
      headers: location_headers(session),
      with_result: &check_result/2,
      metrics_url: config(session, :base_url) <> "/api/v1/users/.../locations",
    ]

    user = session.assigned.user_id

    session
    |> post("api/v1/users/" <> user <> "/locations", opts)
  end

  defp location_body() do
    %{
      location: %{
        coords: %{
          latitude: Address.latitude(),
          longitude: Address.longitude(),
          accuracy: 1.0
        }
      },
      device: "overseer"
    }
  end

  defp location_headers(session) do
    %{
      "Content-Type" => "application/json",
      "authentication" => "Bearer " <> session.assigned.location_token
    }
  end

  defp check_result(session, %{status_code: 201}), do: session

  def set_timeout(session, timeout),
    do: update_config(session, timeout: fn _ -> timeout end)
end
