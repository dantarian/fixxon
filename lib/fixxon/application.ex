defmodule Fixxon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FixxonWeb.Telemetry,
      Fixxon.Repo,
      {DNSCluster, query: Application.get_env(:fixxon, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Fixxon.PubSub},
      Pow.Store.Backend.MnesiaCache,
      {Fixxon.RateLimit, clean_period: :timer.minutes(5)},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Fixxon.Finch},
      # Start a worker by calling: Fixxon.Worker.start_link(arg)
      # {Fixxon.Worker, arg},
      # Start to serve requests, typically the last entry
      FixxonWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fixxon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FixxonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
