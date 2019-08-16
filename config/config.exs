# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bank,
  ecto_repos: [Bank.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :bank, BankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I1eQs7Xk1KBNoSXY0xI/d3xaaxRYaHzJSUYbKSmMBEaeMpI6Fp2iRnpeypc1xGtR",
  render_errors: [view: BankWeb.ErrorView, accepts: ~w(json)]

# Configure your database
config :bank, Bank.Repo, migration_primary_key: [name: :id, type: :binary_id]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Argon2 library
config :argon2_elixir, argon2_type: 2

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
