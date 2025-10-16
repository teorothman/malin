defmodule Malin.Content.ContentItem do
  use Ash.Resource,
    otp_app: :malin,
    domain: Malin.Content,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "content_items"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :content_type, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:pdf, :video, :text_article, :guide, :external_link]
    end

    attribute :icon, :atom do
      public? true
      constraints one_of: [
        :cake,
        :check,
        :clipboard,
        :"cursor-arrow-rays",
        :"face-smile",
        :gift,
        :"globe-europe-africa",
        :heart,
        :key,
        :map,
        :"presentation-chart-bar",
        :star,
        :sun,
        :trophy,
        :"video-camera",
        :bolt,
        :"play-circle"
      ]
    end

    attribute :file_url, :string do
      public? true
    end

    attribute :video_url, :string do
      public? true
    end

    attribute :body, :string do
      public? true
    end

    attribute :external_url, :string do
      public? true
    end

    attribute :state, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:draft, :published, :archived]
      default :draft
    end

    attribute :published_at, :datetime do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :author, Malin.Accounts.User do
      allow_nil? false
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if actor_present()
    end

    policy action([:create, :update, :destroy]) do
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
      prepare build(load: [:author], sort: [published_at: :desc])
    end

    read :list do
      pagination do
        required? false
        offset? true
        countable true
      end

      prepare build(load: [:author], sort: [inserted_at: :desc])
    end

    read :show do
      get? true
      get_by [:id]
      prepare build(load: [:author])
    end

    create :create do
      primary? true

      accept [
        :title,
        :description,
        :content_type,
        :icon,
        :file_url,
        :video_url,
        :body,
        :external_url,
        :state,
        :published_at
      ]

      change relate_actor(:author)
    end

    update :update do
      primary? true
      require_atomic? false

      accept [
        :title,
        :description,
        :content_type,
        :icon,
        :file_url,
        :video_url,
        :body,
        :external_url,
        :state,
        :published_at
      ]
    end
  end
end
