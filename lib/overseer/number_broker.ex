defmodule Overseer.NumberBroker do
  @moduledoc """
  A server to allocate random phone numbers with preconfigured constraints
  (such as lenth and prefix) to requesting processes 
  """

  use GenServer

  @total_numbers 100_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  @impl true
  def init(_) do
    numbers =
      :overseer
      |> Confex.get_env(:number_prefix)
      |> make_numbers()

    {:ok, numbers}
  end

  @impl true
  def handle_call(:get, _from, numbers) do
    index = (numbers |> length() |> :rand.uniform()) - 1
    {number, rest} = List.pop_at(numbers, index)

    {:reply, number, rest}
  end

  defp make_numbers(prefix) do
    Enum.map(1..@total_numbers, fn n ->
      suffix = n |> Integer.to_string() |> String.pad_leading(7, "0")
      prefix <> suffix
    end)
  end
end
