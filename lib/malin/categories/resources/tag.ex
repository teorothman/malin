defmodule Malin.Categories.Tag do
  use Ash.Resource,
    domain: Malin.Categories,
    data_layer: AshPostgres.DataLayer

  postgres do
    schema "categories"
    table "tags"
    repo Malin.Repo
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
    end

    create :create do
      primary? true
      argument :posts, {:array, :integer}
      change manage_relationship(:posts, type: :append_and_remove, on_no_match: :create)
    end

    update :update do
      accept [:name]
    end
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
end
