defmodule NetwatcherWeb.StreamLive do
  use NetwatcherWeb, :live_view

  @topic "sources"

  def render(assigns) do
    case assigns.sources do
      [] ->
        ~H"""
        <p>No sources connected!</p>
        """
      _ ->
        ~H"""
        <%= for source <- @sources do %>
          <video id={source.id} muted autoplay data-source={source.source} phx-hook="InitHls"></video>
        <% end %>
        """
    end
  end

  def mount(_params, _session, socket) do
    NetwatcherWeb.Endpoint.subscribe(@topic)
    sources = SourceRegistry.list()
    {:ok, assign(socket, :sources, sources)}
  end

  def handle_info(%{topic: @topic, payload: _source}, socket) do
    sources = SourceRegistry.list()
    {:noreply, assign(socket, :sources, sources)}
  end
end
