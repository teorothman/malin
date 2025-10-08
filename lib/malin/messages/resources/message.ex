defmodule Malin.Messages.Message do
  use Ash.Resource,
    otp_app: :malin,
    domain: Malin.Messages,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema "messages"
    table "messages"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false

    attribute :read_at, :utc_datetime
    timestamps()
  end

  relationships do
    belongs_to :user, Malin.Accounts.User, allow_nil?: false
  end

  policies do
    # Allow anyone to create messages (for contact forms)
    policy action_type(:create) do
      authorize_if always()
    end

    policy action(:toggle_read) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    # Allow admins to read all messages, users to read their own
    policy action_type(:read) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if relates_to_actor_via(:user)
    end

    # Only admins can update/destroy messages
    policy action_type([:update, :destroy]) do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  actions do
    defaults [:create, :update, :destroy]
    default_accept [:content, :user_id]

    read :read do
      primary? true
      prepare build(sort: [inserted_at: :desc])
    end

    update :toggle_read do
      require_atomic? false
      description "Toggle the read status of a message"
      accept []

      change fn changeset, _context ->
        record = changeset.data

        new_read_at =
          if is_nil(record.read_at) do
            DateTime.utc_now()
          else
            nil
          end

        Ash.Changeset.change_attribute(changeset, :read_at, new_read_at)
      end
    end

    create :create_with_user do
      accept [:content, :user_id]
    end

    read :get_by_id do
      description "Get a single message by ID"
      get? true

      argument :id, :uuid do
        allow_nil? false
      end

      filter expr(id == ^arg(:id))
      prepare build(load: [:user])
    end

    read :list_unread do
      description "List messages that haven't been read yet"

      filter expr(is_nil(read_at))

      prepare build(load: [:user], sort: [inserted_at: :desc])
    end
  end

  validations do
    validate present(:content)
    validate string_length(:content, min: 1, max: 1000)
  end
end
