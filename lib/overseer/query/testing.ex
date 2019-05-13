defmodule Overseer.Query.Testing do
  @moduledoc "Testing-related GraphQL queries"

  def factory_insert(input) do
    {
      """
      mutation ($input: [FactoryInsertInput]) {
        factoryInsert (input: $input) {
          result
          successful
        }
      }
      """,
      %{input: Enum.map(input, &make_input/1)}
    }
  end

  defp make_input({type, params}), do: make_input({1, type, params})

  defp make_input({count, type, params}) do
    %{
      count: count,
      type: type,
      atomParams: get_params(params, &is_atom/1),
      boolParams: get_params(params, &is_boolean/1),
      floatParams: get_params(params, &is_float/1),
      intParams: get_params(params, &is_integer/1),
      stringParams: get_params(params, &is_binary/1)
    }
  end

  defp get_params(params, fun) do
    params
    |> Enum.filter(fn {_k, v} -> fun.(v) end)
    |> Enum.map(fn {k, v} -> %{key: k, value: v} end)
  end
end
