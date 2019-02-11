defmodule Overseer do
  @moduledoc """
  Documentation for Overseer.
  """

  require Logger

  use Application

  alias Overseer.{Client, Incident, Op}

  def start(_type, _args) do
    Logger.info("Starting Overseer")

    Supervisor.start_link(
      [
        Client.supervisor(async: false)
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
    module = Module.concat([Op, module])

    with {:module, _} <- Code.ensure_loaded(module),
         true <- Kernel.function_exported?(module, :run, length(args)) do
      run_module_op(module, args)
    else
      _ ->
        Logger.error("""
        Could not find #{inspect(module)}.run/#{inspect(length(args))}
        """)
    end
  end

  def run_module_op(module, args) do
    try do
      apply(module, :run, args)
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
