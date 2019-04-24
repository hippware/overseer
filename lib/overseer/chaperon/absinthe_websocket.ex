defmodule Overseer.Chaperon.AbsintheWebsocket do
  @moduledoc """
  Wrapper module to add Absinthe-specific websocket functionality to the
  default chaperon websocket. For the Absinthe-specific stuff, use
  `aws_<command>` ratehr than `ws_<command>` - eg `aws_send`.
  """

  use Chaperon.Scenario

  def aws_connect(session, path, options \\ []) do
    msg =
      %{
        topic: "__absinthe__:control",
        event: "phx_join",
        payload: %{},
        ref: 0
      }
      |> Poison.encode!()

    session
    |> ws_connect(path, options)
    |> log_info("Joining control channel")
    |> ws_send(msg, options)
    |> assign(msg_ref: 1)
    |> update_config(interval: fn _ -> {30_000, &send_heartbeat/1} end)
    |> aws_recv()
  end

  def aws_send(session, {query, vars}, options \\ []) do
    doc = %{
      "query" => query,
      "variables" => vars
    }

    msg =
      %{
        topic: "__absinthe__:control",
        event: "doc",
        payload: doc,
        ref: session.assigned.msg_ref
      }
      |> Poison.encode!()

    session
    |> ws_send(msg, options)
    |> update_assign(msg_ref: &(&1 + 1))
  end

  def aws_recv(session, options \\ []) do
    session
    |> ws_recv(
      Keyword.merge(options, decode: :json, with_result: &store_last/2)
    )
    |> check_ref()
  end

  def aws_await_recv(session, expected_message, options \\ []) do
    ws_await_recv(session, expected_message, options)
  end

  def aws_close(session, options \\ []), do: ws_close(session, options)

  defp send_heartbeat(session) do
    msg =
      %{
        topic: "phoenix",
        event: "heartbeat",
        payload: "",
        ref: session.assigned.msg_ref
      }
      |> Poison.encode!()

    session
    |> ws_send(msg, [])
    |> update_assign(msg_ref: &(&1 + 1))
    |> ws_await_recv(&check_heartbeat_response/1)
  end

  def get_last(session), do: session.assigned.last_msg

  defp store_last(session, msg) do
    session
    |> assign(last_msg: msg)
  end

  defp check_ref(session) do
    msg = session.assigned.last_msg

    if msg.ref == session.assigned.msg_ref - 1 &&
         msg.topic == "__absinthe__:control" && msg.payload.status == "ok" do
      session
    else
      error(session, "Packet match error")
    end
  end

  defp check_heartbeat_response(_msg) do
    # TODO
    true
  end
end
