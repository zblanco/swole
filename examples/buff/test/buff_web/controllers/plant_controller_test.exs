defmodule BuffWeb.PlantControllerTest do
  use BuffWeb.ConnCase

  import Buff.FarmingFixtures

  alias Buff.Farming.Plant

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all plants", %{conn: conn} do
      conn = get(conn, ~p"/api/plants") |> doc(Buff.Swole, operation_id: "list_plants")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create plant" do
    test "renders plant when data is valid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/plants", plant: @create_attrs)
        |> doc(Buff.Swole, operation_id: "create_plant")

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/plants/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/plants", plant: @invalid_attrs)
        |> doc(Buff.Swole, operation_id: "create_plant")

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update plant" do
    setup [:create_plant]

    test "renders plant when data is valid", %{conn: conn, plant: %Plant{id: id} = plant} do
      conn =
        put(conn, ~p"/api/plants/#{plant}", plant: @update_attrs)
        |> doc(Buff.Swole, operation_id: "update_plant")

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/plants/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, plant: plant} do
      conn =
        put(conn, ~p"/api/plants/#{plant}", plant: @invalid_attrs)
        |> doc(Buff.Swole, operation_id: "update_plant")

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete plant" do
    setup [:create_plant]

    test "deletes chosen plant", %{conn: conn, plant: plant} do
      conn =
        delete(conn, ~p"/api/plants/#{plant}") |> doc(Buff.Swole, operation_id: "delete_plant")

      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/api/plants/#{plant}")
      end)
    end
  end

  defp create_plant(_) do
    plant = plant_fixture()
    %{plant: plant}
  end
end
