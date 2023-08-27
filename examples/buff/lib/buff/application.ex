defmodule Buff.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BuffWeb.Telemetry,
      # Start the Ecto repository
      Buff.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Buff.PubSub},
      # Start the Endpoint (http/https)
      BuffWeb.Endpoint
      # Start a worker by calling: Buff.Worker.start_link(arg)
      # {Buff.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Buff.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BuffWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
