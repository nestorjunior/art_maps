defmodule ArtMaps.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string, null: false
      add :photo_url, :string
      add :bio, :text
      add :website, :string
      add :instagram, :string
      add :contact, :string

      timestamps(type: :utc_datetime)
    end
  end
end
