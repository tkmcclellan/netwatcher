defmodule NetwatcherWeb.StreamLive do
  use NetwatcherWeb, :live_view

  @topic "sources"

  def render(assigns) do
    ~H"""
    Stream Sources:
    <ul>
      <%= for source <- @sources do %>
        <li>{source.id}</li>
      <% end %>
    </ul>

    <%= if @focus do %>
      <.modal id="focus_modal" show={true} on_cancel={JS.push("clear_focus")}>
        <.source id={@focus.id} source={@focus.source} />
      </.modal>
    <% end %>

    <%= case assigns.sources do %>
      <% [] -> %>
        <p>No sources connected!</p>
      <% _ -> %>
        <%= for source <- @sources do %>
          <.source id={source.id} source={source.source} />
        <% end %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    NetwatcherWeb.Endpoint.subscribe(@topic)
    sources = SourceRegistry.list()
    {:ok, assign(socket, sources: sources, focus: nil)}
  end

  def handle_info(%{topic: @topic, payload: _source}, socket) do
    sources = SourceRegistry.list()
    {:noreply, assign(socket, :sources, sources)}
  end

  def handle_event("focus_stream", %{"id" => id}, socket) do
    source = Enum.find(socket.assigns.sources, fn x -> x.id == id end)

    dbg(source)
    if source != nil do
      {:noreply, assign(socket, :focus, source)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("clear_focus", _params, socket) do
    {:noreply, assign(socket, :focus, nil)}
  end

  attr :id, :string, required: true
  attr :source, :string, required: true
  def source(assigns) do
    ~H"""
    <video id={@id} muted autoplay data-source={@source} phx-hook="InitHls" phx-click="focus_stream" phx-value-id={@id}></video>
    """
  end
end
