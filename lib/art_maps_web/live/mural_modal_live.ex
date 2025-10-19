defmodule ArtMapsWeb.MuralSidebarLive do
  use ArtMapsWeb, :live_component

  alias ArtMaps.Murals

  @impl true
  def update(%{mural: mural}, socket) do
    artist = Murals.get_artist_for_mural(mural)
    murals_by_artist = Murals.list_murals_by_artist(artist.id)

    {:ok,
     socket
     |> assign(:mural, mural)
     |> assign(:artist, artist)
     |> assign(:murals_by_artist, murals_by_artist)
     |> assign(:tab, :mural)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <nav class="fixed left-0 top-0 h-full w-96 bg-white shadow-lg z-40 flex flex-col">
        <div class="flex border-b">
          <button phx-click="tab" phx-value-tab="mural" class={tab_class(@tab, :mural)}>🖼️ Mural</button>
          <button phx-click="tab" phx-value-tab="artist" class={tab_class(@tab, :artist)}>🎨 Sobre o artista</button>
          <button phx-click="tab" phx-value-tab="profile" class={tab_class(@tab, :profile)}>📁 Perfil do artista</button>
        </div>
        <div class="flex-1 overflow-y-auto">
          <%= if @tab == :mural do %>
            <div class="p-4">
              <img src={@mural.image_url} alt="Mural" class="w-full h-64 object-cover rounded mb-4" />
              <h2 class="text-xl font-bold mb-2">{@mural.title}</h2>
              <p class="text-sm text-gray-600 mb-1">Artista: {@artist.name}</p>
              <p class="text-sm text-gray-600 mb-1">Localização: {@mural.city}, {@mural.location}</p>
              <p class="mb-4">{@mural.description}</p>
              <div class="flex gap-2">
                <button phx-click="favorite" class="btn">❤️ Favoritar</button>
                <button phx-click="share" class="btn">🔗 Compartilhar</button>
                <a href={@mural.street_view_url} target="_blank" class="btn">👁️ Ver no Street View</a>
              </div>
            </div>
          <% end %>
          <%= if @tab == :artist do %>
            <div class="p-4">
              <img src={@artist.photo_url} alt="Artista" class="w-24 h-24 rounded-full mb-2" />
              <h2 class="text-lg font-bold mb-2">{@artist.name}</h2>
              <p class="mb-2">{@artist.bio}</p>
              <div class="flex gap-2">
                <a href={@artist.website} target="_blank" class="btn">Site</a>
                <a href={@artist.instagram} target="_blank" class="btn">Instagram</a>
                <a href={@artist.contact} target="_blank" class="btn">Contato</a>
              </div>
            </div>
          <% end %>
          <%= if @tab == :profile do %>
            <div class="p-4">
              <h2 class="text-lg font-bold mb-4">Murais do artista</h2>
              <div class="grid grid-cols-1 gap-2">
                <%= for mural <- @murals_by_artist do %>
                  <div class="flex items-center gap-2 border rounded p-2">
                    <img src={mural.image_url} alt="Mural" class="w-16 h-16 object-cover rounded" />
                    <div>
                      <div class="font-semibold">{mural.title}</div>
                      <div class="text-xs text-gray-600">{mural.city}</div>
                      <button phx-click="goto_mural" phx-value-id={mural.id} class="btn">Ver no mapa</button>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </nav>
    """
  end

  defp tab_class(current, tab) do
    if current == tab, do: "px-4 py-2 font-bold border-b-2 border-blue-500", else: "px-4 py-2"
  end
end
