defmodule ArtMaps.Repo.Migrations.AddArtistIdToMurals do
  use Ecto.Migration

  def change do
    alter table(:murals) do
      add :artist_id, references(:artists, on_delete: :nilify_all)
    end

    create index(:murals, [:artist_id])
  end
end
