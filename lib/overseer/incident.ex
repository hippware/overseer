defmodule Overseer.Incident do
  @moduledoc """
  Module for creating pagerduty incidents for test failures
  """

  def create(module, data) do
    if Confex.get_env(:overseer, :enable_pagerduty), do: do_create(module, data)
  end

  defp do_create(module, data) do
    client = Mixduty.Client.new(Confex.get_env(:overseer, :pagerduty_key))

    title = "Overseer error in #{module}"

    body = %{
      type: "incident_body",
      details: inspect(data)
    }

    Mixduty.Incidents.create(
      title,
      Confex.get_env(:overseer, :pagerduty_service),
      Confex.get_env(:overseer, :pagerduty_user),
      client,
      %{body: body}
    )
  end
end
