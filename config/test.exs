use Mix.Config

# Configure your database
config :blog, Blog.Repo,
  username: "postgres",
  password: "postgres",
  database: "blog_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blog, BlogWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn


# Password hashing test config
config :argon2_elixir, t_cost: 1, m_cost: 8
#config :bcrypt_elixir, log_rounds: 4
#config :pbkdf2_elixir, rounds: 1
