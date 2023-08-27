defmodule Buff.FarmingTest do
  use Buff.DataCase

  alias Buff.Farming

  describe "plants" do
    alias Buff.Farming.Plant

    import Buff.FarmingFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_plants/0 returns all plants" do
      plant = plant_fixture()
      assert Farming.list_plants() == [plant]
    end

    test "get_plant!/1 returns the plant with given id" do
      plant = plant_fixture()
      assert Farming.get_plant!(plant.id) == plant
    end

    test "create_plant/1 with valid data creates a plant" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Plant{} = plant} = Farming.create_plant(valid_attrs)
      assert plant.description == "some description"
      assert plant.name == "some name"
    end

    test "create_plant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Farming.create_plant(@invalid_attrs)
    end

    test "update_plant/2 with valid data updates the plant" do
      plant = plant_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Plant{} = plant} = Farming.update_plant(plant, update_attrs)
      assert plant.description == "some updated description"
      assert plant.name == "some updated name"
    end

    test "update_plant/2 with invalid data returns error changeset" do
      plant = plant_fixture()
      assert {:error, %Ecto.Changeset{}} = Farming.update_plant(plant, @invalid_attrs)
      assert plant == Farming.get_plant!(plant.id)
    end

    test "delete_plant/1 deletes the plant" do
      plant = plant_fixture()
      assert {:ok, %Plant{}} = Farming.delete_plant(plant)
      assert_raise Ecto.NoResultsError, fn -> Farming.get_plant!(plant.id) end
    end

    test "change_plant/1 returns a plant changeset" do
      plant = plant_fixture()
      assert %Ecto.Changeset{} = Farming.change_plant(plant)
    end
  end
end
