import Config
config :malin, token_signing_secret: "dtzhgrdAVrx+5iladIU5L8ESkk6zsLyR"
config :ash, disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :malin, Malin.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "malin_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :malin, MalinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "n1qHdp72mVkrBhDs3By+t/Tox14XO2LPYkAAms6nZdP8MX448cc9utSKxXmSMMn7",
  server: false

# In test we don't send emails
config :malin, Malin.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
