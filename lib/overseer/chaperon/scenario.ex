defmodule Overseer.Chaperon.Scenario do
  @moduledoc "To be `use`d by scenarios running against and Absinthe websocket"

  defmacro __using__(_opts) do
    quote do
      use Chaperon.Scenario
      import Overseer.Chaperon.AbsintheWebsocket
    end
  end
end
