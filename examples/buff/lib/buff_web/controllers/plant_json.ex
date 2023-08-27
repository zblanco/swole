defmodule BuffWeb.PlantJSON do
  alias Buff.Farming.Plant

  @doc """
  Renders a list of plants.
  """
  def index(%{plants: plants}) do
    %{data: for(plant <- plants, do: data(plant))}
  end

  @doc """
  Renders a single plant.
  """
  def show(%{plant: plant}) do
    %{data: data(plant)}
  end

  defp data(%Plant{} = plant) do
    %{
      id: plant.id,
      name: plant.name,
      description: plant.description
    }
  end
end
