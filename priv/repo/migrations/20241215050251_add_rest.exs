defmodule Malin.Repo.Migrations.AddRest do
  use Ecto.Migration

  def up do
    execute "CREATE SCHEMA IF NOT EXISTS posts"
    execute "CREATE SCHEMA IF NOT EXISTS categories"

    create table(:tags, primary_key: false, prefix: "categories") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
    end

    create table(:post_tags, primary_key: false, prefix: "categories") do
      add :post_id, :uuid, null: false, primary_key: true
      add :tag_id, :uuid, null: false, primary_key: true
    end

    create table(:posts, primary_key: false, prefix: "posts") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:post_tags, prefix: "categories") do
      modify :post_id,
             references(:posts,
               column: :id,
               name: "post_tags_post_id_fkey",
               type: :uuid,
               prefix: "posts",
               on_delete: :delete_all
             )

      modify :tag_id,
             references(:tags,
               column: :id,
               name: "post_tags_tag_id_fkey",
               type: :uuid,
               prefix: "categories",
               on_delete: :delete_all
             )
    end

    alter table(:posts, prefix: "posts") do
      add :title, :text, null: false
      add :public, :boolean, null: false, default: false
      add :intro, :text, null: false
      add :text, :text, null: false
      add :publish_at, :utc_datetime
      add :state, :text, null: false, default: "draft"

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :author_id,
          references(:users,
            column: :id,
            name: "posts_author_id_fkey",
            type: :uuid,
            # Updated to use accounts schema
            prefix: "accounts",
            on_delete: :restrict
          ),
          null: false

      add :category_id, :uuid, null: false
    end

    create table(:comments, primary_key: false, prefix: "posts") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :text, :text, null: false

      add :user_id,
          references(:users,
            column: :id,
            name: "comments_user_id_fkey",
            type: :uuid,
            # Updated to use accounts schema
            prefix: "accounts",
            on_delete: :restrict
          ),
          null: false

      add :post_id,
          references(:posts,
            column: :id,
            name: "comments_post_id_fkey",
            type: :uuid,
            prefix: "posts",
            on_delete: :delete_all
          ),
          null: false
    end

    create table(:categories, primary_key: false, prefix: "categories") do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:posts, prefix: "posts") do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "posts_category_id_fkey",
               type: :uuid,
               prefix: "categories",
               on_delete: :restrict
             )
    end

    alter table(:categories, prefix: "categories") do
      add :name, :text, null: false
      add :description, :text
    end

    execute "GRANT USAGE ON SCHEMA posts TO postgres"
    execute "GRANT USAGE ON SCHEMA categories TO postgres"
  end

  def down do
    # The down function remains mostly unchanged, but ensure all references point to the correct schema.
    # For example, user_id and author_id references should use "accounts" in the rollback as well.
    # Adjust as necessary.
  end
end
