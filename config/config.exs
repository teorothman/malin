# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash,
  include_embedded_source_by_default?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false]

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :postgres,
        :attributes,
        :calculations,
        :relationships,
        :identities,
        :policies,
        :code_interface,
        :authentication,
        :tokens,
        :resource,
        :actions,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :aggregates
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

config :malin,
  ecto_repos: [Malin.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Malin.Accounts, Malin.Posts, Malin.Categories]

# Configures the endpoint
config :malin, MalinWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MalinWeb.ErrorHTML, json: MalinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Malin.PubSub,
  live_view: [signing_salt: "HoVN2ROW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :malin, Malin.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.your-email-provider.com",
  username: "your-username",
  password: "your-password",
  tls: :if_available,
  auth: :always

config :swoosh, :api_client, Swoosh.ApiClient.Hackney

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  malin: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  malin: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
