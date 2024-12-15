defmodule Malin.Repo.Migrations.AddMagicLinkAuth do
  use Ecto.Migration

  def up do
    alter table(:users, prefix: "accounts") do
      add :email, :citext, null: false
    end

    create unique_index(:users, [:email], name: "users_unique_email_index", prefix: "accounts")
  end

  def down do
    drop_if_exists unique_index(:users, [:email],
                     name: "users_unique_email_index",
                     prefix: "accounts"
                   )

    alter table(:users, prefix: "accounts") do
      remove :email
    end
  end
end
