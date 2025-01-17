defmodule Malin.Repo.Migrations.ChangeLastNameToString do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:forms, prefix: "posts") do
      modify :last_name, :text, default: "false"
    end
  end

  def down do
    alter table(:forms, prefix: "posts") do
      modify :last_name, :boolean, default: false
    end
  end
end
