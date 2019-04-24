defmodule Overseer.Scenario.Geofence do
  @moduledoc """
  * Create bots and a set of users subscribed to those bots.
  * Send repeated location updates from those users.
  """

  use Overseer.Chaperon.Scenario

  alias Faker.Address
  alias Overseer.Query.{Testing, User}
  alias Overseer.Scenario.Utils

  def init(session), do: {:ok, session}

  def run(session!) do
    bot_count = config(session!, [:geofence, :bots])
    friend_count = config(session!, [:geofence, :friends])

    session! = Utils.authenticate(session!)
    user_id = session!.assigned.user_id

    session! =
      session!
      |> log_info("Creating bots")
      |> aws_send(
        Testing.factory_insert([{bot_count, :bot, %{user_id: user_id}}])
      )
      |> aws_recv()

    bots = hd(get_last(session!).payload.response.data.factoryInsert.result)

    session!
    |> set_timeout(:infinity)
    |> repeat(:async_friend, [user_id, bots], friend_count)
    |> log_warn("Friends ready - sending GO")
    |> signal(:friend, :go)
    |> await_all(:friend)
  end

  def async_friend(session!, user_id, bots) do
    session!
    |> async(:run_friend, [user_id, bots], :friend)
    |> await_signal(:friend_ready)
  end

  def run_friend(session!, friend_id, bots) do
    location_count = config(session!, [:geofence, :locations])
    session! = Utils.authenticate(session!)
    user_id = session!.assigned.user_id

    session!
    |> aws_send(
      Testing.factory_insert([
        {:roster_item, %{user_id: user_id, contact_id: friend_id}},
        {:roster_item, %{user_id: friend_id, contact_id: user_id}}
        | Enum.map(bots, &{:subscription, %{bot_id: &1, user_id: user_id}})
      ])
    )
    |> aws_recv()
    |> signal_parent(:friend_ready)
    |> await_signal(:go)
    |> repeat_traced(:send_location, location_count)
    |> aws_close()
  end

  def send_location(session!) do
    session!
    |> aws_send(User.send_location(Address.latitude(), Address.longitude()))
    |> aws_recv()
  end

  def set_timeout(session, timeout),
    do: update_config(session, timeout: fn _ -> timeout end)

  def teardown(session) do
    session
    |> aws_send(User.delete())
    |> aws_close()
  end
end
