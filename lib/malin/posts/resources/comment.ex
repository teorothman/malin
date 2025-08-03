defmodule Malin.Posts.Comment do
  use Ash.Resource,
    domain: Malin.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema "posts"
    table "comments"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id, writable?: true
    attribute :text, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Malin.Accounts.User do
      domain Malin.Accounts
      public? true
      primary_key? true
      allow_nil? false
    end

    belongs_to :post, Malin.Posts.Post do
      domain Malin.Posts
      public? true
      primary_key? true
      allow_nil? false
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if actor_present()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:update) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action_type(:destroy) do
      authorize_if expr(id == ^actor(:id))
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true

      pagination do
        required? false
        offset? true
        countable true
      end
    end

    create :create do
      accept [:text, :user_id, :post_id]
    end

    update :update do
      accept [:text, :user_id, :post_id]
    end
  end
end
