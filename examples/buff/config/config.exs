# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :buff,
  ecto_repos: [Buff.Repo]

# Configures the endpoint
config :buff, BuffWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: BuffWeb.ErrorHTML, json: BuffWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Buff.PubSub,
  live_view: [signing_salt: "9Fj72X08"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
