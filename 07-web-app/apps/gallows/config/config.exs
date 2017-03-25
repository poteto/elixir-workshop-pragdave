# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :gallows, Gallows.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "k16i7Pa4SPjEiqI5tsw+eOhRq6KaZXvORA9pDhu4WNPxUOklE38EeH4y8Jwg0Jhi",
  render_errors: [view: Gallows.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gallows.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
