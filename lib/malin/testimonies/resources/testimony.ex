defmodule Malin.Testimonies.Testimony do
  use Ash.Resource,
    otp_app: :malin,
    domain: Malin.Testimonies,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema "testimonies"
    table "testimonies"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false
    attribute :content, :string, allow_nil?: false

    attribute :author, :string, allow_nil?: false

    timestamps()
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action([
             :create,
             :update,
             :destroy
           ]) do
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

    read :list do
      pagination do
        required? false
        offset? true
        countable true
      end
    end

    create :create do
      primary? true
      accept [:title, :content, :author]
    end

    update :update do
      require_atomic? false
      accept [:title, :content, :author]
    end
  end
end
