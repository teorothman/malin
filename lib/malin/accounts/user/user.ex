defmodule Malin.Accounts.User do
  use Ash.Resource,
    otp_app: :malin,
    domain: Malin.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  postgres do
    schema "accounts"
    table "users"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:user, :admin, :applicant]
      default :applicant
      sortable? false
      public? false
    end

    attribute :application_note, :string do
      allow_nil? true
      public? false
    end

    attribute :first_name, :string do
      allow_nil? true
      public? false
    end

    attribute :last_name, :string do
      allow_nil? true
      public? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :name, :string, expr(first_name <> " " <> last_name), public?: true, sortable?: true
  end

  relationships do
    has_many :messages, Malin.Messages.Message
  end

  identities do
    identity :unique_email, [:email]
    identity :primary_key, [:id]
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      authorize_if always()
    end
  end

  authentication do
    tokens do
      enabled? true
      token_resource Malin.Accounts.Token
      signing_secret Malin.Secrets
    end

    strategies do
      magic_link do
        identity_field :email
        registration_enabled? true

        sender Malin.Accounts.User.Senders.SendMagicLinkEmail
        lookup_action_name :get_by_email
        sign_in_action_name :sign_in_with_magic_link
      end
    end
  end

  actions do
    defaults [:read]

    read :show do
      get? true
      get_by :id
    end

    create :register do
      accept [:email, :application_note, :first_name, :last_name]
      upsert? true
      upsert_identity :unique_email
    end

    update :update do
      primary? true
      require_atomic? false
      accept [:email, :role]
    end

    read :list_for_admin do
      description "List users with optional email search and role filtering for admin"

      argument :search_email, :string do
        allow_nil? true
        description "Search users by email"
      end

      argument :filter_role, :atom do
        allow_nil? true
        constraints one_of: [:user, :admin, :applicant]
        description "Filter users by role"
      end

      filter expr(
               if is_nil(^arg(:search_email)) or ^arg(:search_email) == "" do
                 true
               else
                 contains(email, ^arg(:search_email))
               end and
                 if is_nil(^arg(:filter_role)) do
                   true
                 else
                   role == ^arg(:filter_role)
                 end
             )

      prepare build(load: [:name, :messages], sort: [inserted_at: :desc])
    end

    read :list_this_week do
      filter expr(inserted_at >= ago(7, :day))

      prepare build(load: :name, sort: [inserted_at: :desc])
    end

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
      prepare build(sort: [inserted_at: :desc])
    end

    read :get_by_email do
      description "Looks up a user by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    create :sign_in_with_magic_link do
      description "Sign in a user with magic link."

      argument :token, :string do
        description "The token from the magic link that was sent to the user"
        allow_nil? false
      end

      # Use the required change for magic link sign-in
      change AshAuthentication.Strategy.MagicLink.SignInChange

      # Enable upserts for signing in or creating the user
      upsert? true
      upsert_identity :unique_email
    end

    action :request_magic_link do
      argument :email, :ci_string do
        allow_nil? false
      end

      run AshAuthentication.Strategy.MagicLink.Request
    end
  end
end
