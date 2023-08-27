defmodule Buff.Repo.Migrations.CreatePlants do
  use Ecto.Migration

  def change do
    create table(:plants) do
      add :name, :string
      add :description, :string

      timestamps()
    end
  end
end
