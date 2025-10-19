defmodule ArtMapsWeb.MapLive do
  use ArtMapsWeb, :live_view

  alias ArtMaps.Murals
  alias ArtMapsWeb.Layouts

  @impl true
  def mount(_params, _session, socket) do
    murals = Murals.list_murals()
    socket =
      socket
      |> assign(:murals, murals)
      |> assign(:page_title, "Mapa de Murais Urbanos")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
      <div class="container mx-auto py-8">
        <h1 class="text-2xl font-bold mb-4">Mapa de Murais Urbanos</h1>
        <div id="map" phx-hook="Map" class="w-full h-[500px] rounded shadow"></div>
        <div class="mt-8">
          <h2 class="text-xl font-semibold mb-2">Murais</h2>
          <ul>
            <%= for mural <- @murals do %>
              <li class="mb-2">
                <strong>{mural.title}</strong> - {mural.location}
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
