defmodule Overseer do
  @moduledoc """
  Documentation for Overseer.
  """

  require Logger

  use Application

  def start(_type, _args) do
    Logger.info "STARTING"
    Supervisor.start_link(
      [
        Overseer.Client.supervisor()
      ],
      strategy: :one_for_one,
      name: Overseer.Supervisor
    )
  end

  def run_op(argv) do
    Logger.info "Overseer arguments: #{inspect argv}"

    case argv do
      [] -> help()
      [module | args] -> run_op(module, args)
    end
  end

  defp help() do
    IO.inspect """
    TODO Help goes here.
    """
  end

  def run_op(module, args) do
    module = Module.concat([Overseer, module])

    with true <- Module.open?(module),
         true <- Module.defines?(module, {:run, length(args)}) do
         module.run(args)
    else
      _ ->
        IO.inspect """
        Could not find #{inspect module}.run/#{inspect length(args)}
        """
    end
  end
end
