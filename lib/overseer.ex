defmodule Overseer do
  @moduledoc """
  Documentation for Overseer.
  """

  require Logger

  use Application

  alias Chaperon.Scenario
  alias Overseer.{Incident, NumberBroker}

  def start(_type, _args) do
    Logger.info("Starting Overseer")

    Supervisor.start_link(
      [
        NumberBroker
      ],
      strategy: :one_for_one,
      name: Overseer.Supervisor
    )
  end

  def run_op(argv) do
    Application.ensure_all_started(:overseer)

    Logger.info("Overseer arguments: #{inspect(argv)}")

    argv
    |> do_run_op()
    |> get_exit_status()
    |> :init.stop()
  end

  def do_run_op([]), do: Logger.error("Operation must be supplied")

  def do_run_op([module | args]) do
    module = Module.safe_concat([Overseer.Scenario, module])

    config = %{
      base_url: Confex.get_env(:overseer, :websocket_base_url),
      args: args
    }

    try do
      Scenario.execute(module, config)
      :ok
    catch
      t, e ->
        text = """
        Test failed: #{inspect(module)} / #{inspect(args)}
        Error: #{inspect(t)}:#{inspect(e)}"
        Stacktrace: #{inspect(__STACKTRACE__)}
        """

        Logger.error(text)

        Incident.create(module, text)

        :fail
    end
  end

  defp get_exit_status(:ok), do: 0
  defp get_exit_status(_), do: 1
end
