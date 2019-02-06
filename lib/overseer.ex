defmodule Overseer do
  @moduledoc """
  Documentation for Overseer.
  """

  require Logger

  use Application

  def start(_type, _args) do
    :ok
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
    module =
      Overseer
      |> to_string()
      |> Kernel.<>(".")
      |> Kernel.<>(module)
      |> String.to_atom()

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
