defmodule ArtMaps.Repo.Migrations.AddUserIdToMurals do
  use Ecto.Migration

  def change do
    alter table(:murals) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end

    create index(:murals, [:user_id])
  end
end
