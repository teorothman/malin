defmodule Malin.Analytics.Pageview do
  use Ash.Resource, otp_app: :malin, domain: Malin.Analytics, data_layer: AshPostgres.DataLayer

  postgres do
    schema "analytics"
    table "pageviews"
    repo Malin.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :path, :string, allow_nil?: false
    attribute :referrer, :string
    attribute :user_agent, :string
    # derived from IP without storing IP
    attribute :country, :string
    # parsed from user_agent
    attribute :browser, :string
    # parsed from user_agent
    attribute :os, :string
    attribute :viewed_at, :utc_datetime_usec, default: &DateTime.utc_now/0
  end

  actions do
    defaults [:read]

    create :track do
      accept [:path, :referrer, :user_agent, :country, :browser, :os]
    end
  end
end
