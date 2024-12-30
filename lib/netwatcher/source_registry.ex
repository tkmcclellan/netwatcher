defmodule SourceRegistry do
  use GenServer

  @name {:global, GlobalSourceRegistry}

  def start_link(default) when is_map(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def register(key) do
    source = %Source{id: key, source: "/video/#{key}.m3u8"}
    GenServer.cast(@name, {:register, source})
    NetwatcherWeb.Endpoint.broadcast("sources", "register", source)

    source
  end

  def deregister(key) do
    GenServer.cast(@name, {:deregister, key})
    NetwatcherWeb.Endpoint.broadcast("sources", "deregister", key)
  end

  def list() do
    GenServer.call(@name, :list)
  end

  @impl true
  def init(sources) do
    {:ok, sources}
  end

  @impl true
  def handle_call(:list, _from, sources) do
    {:reply, Map.values(sources), sources}
  end

  @impl true
  def handle_cast({:register, source}, state) do
    if Enum.find(state, fn x -> x == source end) != nil do
      {:noreply, state}
    else
      {:noreply, Map.put(state, source.id, source)}
    end
  end

  @impl true
  def handle_cast({:deregister, key}, state) do
    {:noreply, Map.delete(state, key)}
  end
end
