defmodule Buff.FarmingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Buff.Farming` context.
  """

  @doc """
  Generate a plant.
  """
  def plant_fixture(attrs \\ %{}) do
    {:ok, plant} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Buff.Farming.create_plant()

    plant
  end
end
