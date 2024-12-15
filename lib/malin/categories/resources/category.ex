defmodule Malin.Categories.Category do
  use Ash.Resource,
    domain: Malin.Categories,
    data_layer: AshPostgres.DataLayer

  postgres do
    schema "categories"
    table "categories"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: true, public?: true
  end

  relationships do
    has_many :posts, Malin.Posts.Post do
      domain Malin.Posts
      public? true
    end
  end

  identities do
    identity :primary_key, [:id]
  end

  actions do
    read :read do
      primary? true
    end
  end
end
