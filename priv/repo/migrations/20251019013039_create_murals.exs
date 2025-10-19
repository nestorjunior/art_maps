defmodule ArtMaps.Repo.Migrations.CreateMurals do
  use Ecto.Migration

  def change do
    create table(:murals) do
      add :title, :string
      add :description, :string
      add :latitude, :float
      add :longitude, :float
      add :image_url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
