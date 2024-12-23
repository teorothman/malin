defmodule Malin.Posts.Post do
  use Ash.Resource,
    domain: Malin.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema "posts"
    table "posts"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false, public?: true
    attribute :public, :boolean, allow_nil?: false, default: false, public?: true
    attribute :intro, :string, allow_nil?: false, public?: true
    attribute :text, :string, allow_nil?: false, public?: true
    attribute :publish_at, :datetime, allow_nil?: true, public?: true

    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :published, :hidden]
      default :draft
    end

    timestamps()
  end

  relationships do
    belongs_to :author, Malin.Accounts.User, allow_nil?: false, public?: true

    belongs_to :category, Malin.Categories.Category, allow_nil?: false, public?: true

    many_to_many :tags, Malin.Categories.Tag do
      domain Malin.Categories
      through Malin.Categories.PostTag
      source_attribute_on_join_resource :post_id
      destination_attribute_on_join_resource :tag_id
    end

    has_many :comments, Malin.Posts.Comment do
      public? true
    end
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

      filter expr(state == :published)
      prepare build(load: [:comments, :category, :tags, :author], sort: [publish_at: :desc])
    end

    read :list do
      pagination do
        required? false
        offset? true
        countable true
      end

      prepare build(load: [:category, :tags, :author], sort: [publish_at: :desc])
    end

    create :create do
      primary? true
      accept [:title, :intro, :text, :publish_at, :state, :category_id]

      argument :tags, {:array, :map}, allow_nil?: true

      change relate_actor(:author)

      change manage_relationship(:tags, type: :append_and_remove, on_no_match: :create)
    end

    update :update do
      require_atomic? false
      accept [:title, :intro, :text, :publish_at, :state, :category_id]

      argument :tags, {:array, :map}, allow_nil?: true
      change manage_relationship(:tags, type: :append_and_remove, on_no_match: :create)
    end
  end
end
