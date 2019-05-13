defmodule Overseer.Scenario.LocationUpload do
  @moduledoc """
  Create a set of users and send repeated location updates from them
  """

  use Overseer.Chaperon.Scenario

  alias Chaperon.Session
  alias Faker.Address
  alias Overseer.Query.User
  alias Overseer.Scenario.Utils

  def init(session), do: {:ok, session}

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
    |> signal_parent(:user_ready)
    |> await_signal(:go)
    |> delay({:random, 3 |> seconds})
    |> repeat_traced(:send_location, location_count)
    |> aws_send(User.delete())
    |> aws_close()
  end

  def send_location(session) do
    session
    |> aws_send(User.send_location(Address.latitude(), Address.longitude()))
    |> aws_recv()
    |> delay(3 |> seconds)
  end

  def set_timeout(session, timeout),
    do: update_config(session, timeout: fn _ -> timeout end)
end
