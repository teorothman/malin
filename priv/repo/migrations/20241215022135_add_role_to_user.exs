defmodule Malin.Repo.Migrations.AddRoleToUser do
  use Ecto.Migration

  def up do
    alter table(:users, prefix: "accounts") do
      add :role, :text, null: false, default: "user"
    end
  end

  def down do
    alter table(:users, prefix: "accounts") do
      remove :role
    end
  end
end
