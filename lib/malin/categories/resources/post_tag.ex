defmodule Malin.Categories.PostTag do
  use Ash.Resource,
    domain: Malin.Categories,
    data_layer: AshPostgres.DataLayer

  postgres do
    schema "categories"
    table "post_tags"
    repo Malin.Repo
  end

  actions do
    defaults [:read, :destroy, :create]
  end

  relationships do
    belongs_to :post, Malin.Posts.Post do
      primary_key? true
      allow_nil? false
    end

    belongs_to :tag, Malin.Categories.Tag do
      primary_key? true
      allow_nil? false
    end
  end
end
