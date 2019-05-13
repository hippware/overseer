defmodule Overseer.LoadTest.CommonConfig do
  @moduledoc "Common configuration for load and system tests"

  def default_config,
    do: %{
      base_url: Confex.get_env(:overseer, :websocket_base_url)
    }
end
