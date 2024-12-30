defmodule Netwatcher.Application do
  @moduledoc false

  use Application

  @port 9006

  @impl true
  def start(_type, _args) do
    File.rm_rf!("output")
    File.mkdir_p("output")

    handle_new_client = fn client_ref, _app, stream_key ->
      {:ok, _supervisor, _pipeline} = Membrane.Pipeline.start_link(RtmpToHlsPipeline, client_ref: client_ref, stream_key: stream_key)
      Membrane.RTMP.Source.ClientHandlerImpl
    end

    children = [
      NetwatcherWeb.Telemetry,
      Netwatcher.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:netwatcher, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:netwatcher, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Netwatcher.PubSub},
      {Finch, name: Netwatcher.Finch},
      {Membrane.RTMPServer, port: @port, handle_new_client: handle_new_client},
      {SourceRegistry, %{}},
      NetwatcherWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Netwatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NetwatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") != nil
  end
end
