defmodule Overseer do
  @moduledoc """
  Documentation for Overseer.
  """

  require Logger

  use Application

  def start(_type, _args) do
    Logger.info("STARTING")

    Supervisor.start_link(
      [
        Overseer.Client.supervisor(async: true)
      ],
      strategy: :one_for_one,
      name: Overseer.Supervisor
    )
  end

  def run_op(argv) do
    Application.ensure_all_started(:overseer)
    Process.sleep(2000)

    Logger.info("Overseer arguments: #{inspect(argv)}")

    r = case argv do
      [] -> Logger.error "Operation must be supplied"
      [module | args] -> run_op(module, args)
    end

    case r do
      :ok -> 0
      _ -> 1
    end
    |> :init.stop()
  end

  def run_op(module, args) do
    module = Module.concat([Overseer.Op, module])

    with {:module, _} <- Code.ensure_loaded(module),
         true <- Kernel.function_exported?(module, :run, length(args)) do
      do_run_op(module, args)
    else
      _ ->
        IO.inspect("""
        Could not find #{inspect(module)}.run/#{inspect(length(args))}
        """)
    end
  end

  def do_run_op(module, args) do
    try do
      apply(module, :run, args)
    catch
      t, e ->
        Logger.error("""
        Test failed: #{inspect(module)} / #{inspect(args)}
        Error: #{inspect(t)}:#{inspect(e)}"
        Stacktrace: #{inspect(__STACKTRACE__)}
        """)
    end
  end
end
