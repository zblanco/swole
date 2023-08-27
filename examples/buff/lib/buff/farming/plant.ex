defmodule Buff.Farming.Plant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plants" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
