defmodule BuffWeb.PlantController do
  use BuffWeb, :controller

  alias Buff.Farming
  alias Buff.Farming.Plant

  action_fallback BuffWeb.FallbackController

  def index(conn, _params) do
    plants = Farming.list_plants()
    render(conn, :index, plants: plants)
  end

  def create(conn, %{"plant" => plant_params}) do
    with {:ok, %Plant{} = plant} <- Farming.create_plant(plant_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/plants/#{plant}")
      |> render(:show, plant: plant)
    end
  end

  def show(conn, %{"id" => id}) do
    plant = Farming.get_plant!(id)
    render(conn, :show, plant: plant)
  end

  def update(conn, %{"id" => id, "plant" => plant_params}) do
    plant = Farming.get_plant!(id)

    with {:ok, %Plant{} = plant} <- Farming.update_plant(plant, plant_params) do
      render(conn, :show, plant: plant)
    end
  end

  def delete(conn, %{"id" => id}) do
    plant = Farming.get_plant!(id)

    with {:ok, %Plant{}} <- Farming.delete_plant(plant) do
      send_resp(conn, :no_content, "")
    end
  end
end
