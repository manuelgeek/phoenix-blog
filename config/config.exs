# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blog,
  ecto_repos: [Blog.Repo]

# Configures the endpoint
config :blog, BlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Qo53VgKYZEafJvTfU+st+OdMDkkAfSiGvBZ4Iaf5X+/UJiQk6INRLbf7L7tvM3kh",
  render_errors: [view: BlogWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Blog.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  user_context: Blog.Accounts,
  crypto_module: Argon2,
  token_module: BlogWeb.Auth.Token

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configuration for scrivener_html
config :scrivener_html,
  routes_helper: Paging.Router.Helpers,
  view_style: :bootstrap

config :phx_izitoast, :opts,
  # bottomRight, bottomLeft, topRight, topLeft, topCenter, 
  position: "topRight",
  # dark,
  theme: "light",
  timeout: 5000,
  close: true,
  titleSize: 18,
  messageSize: 18,
  progressBar: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
