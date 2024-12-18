defmodule Malin.Categories.Tag do
  use Ash.Resource,
    domain: Malin.Categories,
    data_layer: AshPostgres.DataLayer

  postgres do
    schema "categories"
    table "tags"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false, public?: true
  end

  relationships do
    many_to_many :posts, Malin.Posts.Post do
      through Malin.Categories.PostTag
      source_attribute_on_join_resource :tag_id
      destination_attribute_on_join_resource :post_id
    end
  end

  identities do
    identity :unique_tag, [:name]
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
    end

    create :create do
      primary? true
      accept [:name]
    end

    update :update do
      accept [:name]
    end
  end
end
