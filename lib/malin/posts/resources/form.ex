defmodule Malin.Posts.Form do
  use Ash.Resource,
    domain: Malin.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema "posts"
    table "forms"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true
    attribute :email, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :background, :string, allow_nil?: true, public?: true
    attribute :discount_code, :string, allow_nil?: true, public?: true

    timestamps()
  end

  policies do
    policy action([
             :read,
             :update,
             :destroy
           ]) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type(:create) do
      authorize_if always()
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
      primary? true
      accept [:first_name, :last_name, :email, :description, :background, :discount_code]
    end

    update :update do
      primary? true
      accept [:first_name, :last_name, :email, :description, :background, :discount_code]
    end
  end
end
