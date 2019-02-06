defmodule Overseer.DummySchema do
  use CommonGraphQLClient.Schema
  api_schema do
    field :id, :integer
    field :name, :string
    field :email, :string
  end

  @cast_params ~w(
    id
    name
    email
  )a

  def changeset(struct, attrs) do
    IO.inspect "CHANGESET"
    struct
    |> cast(attrs, @cast_params)
  end
end
