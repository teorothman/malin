defmodule Malin.Repo.Migrations.AddAuthenticationResources do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  and updated to use the `accounts` schema.
  """

  use Ecto.Migration

  def up do
    execute("CREATE SCHEMA IF NOT EXISTS accounts")

    create table(:users, primary_key: false, prefix: "accounts") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    create table(:tokens, primary_key: false, prefix: "accounts") do
      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :jti, :text, null: false, primary_key: true
      add :subject, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :purpose, :text, null: false
      add :extra_data, :map

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    drop table(:tokens, prefix: "accounts")
    drop table(:users, prefix: "accounts")

    execute("DROP SCHEMA IF EXISTS accounts CASCADE")
  end
end
