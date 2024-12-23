defmodule Malin.Repo.Migrations.AddTableForm do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:forms, primary_key: false, prefix: "posts") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :first_name, :text, null: false
      add :last_name, :boolean, null: false, default: false
      add :email, :text, null: false
      add :description, :text, null: false
      add :background, :text
      add :discount_code, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    drop table(:forms, prefix: "posts")
  end
end