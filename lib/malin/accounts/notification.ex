defmodule Malin.Accounts.Notification do
  use Ash.Resource,
    otp_app: :malin,
    domain: Malin.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub]

  postgres do
    schema "accounts"
    table "notifications"
    repo Malin.Repo

    references do
      reference :user, index?: true, on_delete: :delete
      reference :post, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :user, Malin.Accounts.User do
      allow_nil? false
    end

    belongs_to :post, Malin.Posts.Post do
      allow_nil? false
    end
  end

  policies do
    policy action(:create) do
      forbid_if always()
    end

    policy action(:for_user) do
      authorize_if actor_present()
    end

    policy action(:destroy) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  actions do
    defaults [:destroy]

    create :create do
      accept [:user_id, :post_id]
    end

    read :for_user do
      prepare build(load: [:post], sort: [inserted_at: :desc])
      filter expr(user_id == ^actor(:id))
    end
  end

  # PubSub configuration for real-time updates
  pub_sub do
    prefix "notifications"
    module MalinWeb.Endpoint
    publish :create, [:user_id]
    publish :destroy, [:user_id]
  end
end
