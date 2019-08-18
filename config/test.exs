use Mix.Config

# Configure your database
config :bank, Bank.Repo,
  username: "postgres",
  password: "postgres",
  database: "bank_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank, BankWeb.Endpoint,
  http: [port: 4002],
  server: false

# Speed up tests with Argon2 encryption
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

# Print only warnings and errors during test
config :logger, level: :warn
