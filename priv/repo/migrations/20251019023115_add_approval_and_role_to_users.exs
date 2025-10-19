defmodule ArtMaps.Repo.Migrations.AddApprovalAndRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :approved, :boolean, default: false, null: false
      add :role, :string, default: "user", null: false
      add :full_name, :string
      add :phone, :string
      add :bio, :text
    end

    create index(:users, [:role])
    create index(:users, [:approved])
  end
end
