defmodule ArtMapsWeb.MapLive do
  use ArtMapsWeb, :live_view

  alias ArtMaps.Murals
  alias ArtMapsWeb.Layouts

  @impl true
  def mount(_params, _session, socket) do
    murals = Murals.list_murals()

    {:ok,
     socket
     |> assign(:murals, murals)
     |> assign(:page_title, "Mapa de Murais Urbanos")
     |> assign(:search_query, "")
     |> assign(:suggestions, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <header class="w-full bg-white shadow flex items-center justify-between px-8 py-2 mb-2">
        <div class="flex items-center gap-4">
          <span class="font-bold text-lg">Art Maps</span>
        </div>
        <nav class="flex gap-6">
          <a href="#" class="hover:underline">Sobre</a>
          <a href="#" class="hover:underline">Cadastro</a>
          <a href="#" class="hover:underline">Busca</a>
          <a href="#" class="hover:underline">Contato</a>
          <a href="#" class="hover:underline">Instagram</a>
        </nav>
        <div>
          <select class="border rounded px-2 py-1">
            <option value="pt">🇧🇷 PT</option>
            <option value="en">🇺🇸 EN</option>
            <option value="es">🇪🇸 ES</option>
          </select>
        </div>
      </header>
      <div class="container mx-auto py-8">
        <div class="flex items-center justify-between mb-4">
          <form phx-change="search" class="relative w-96">
            <input type="text" name="q" value={@search_query} placeholder="Buscar mural, artista ou cidade..." class="w-full px-3 py-2 border rounded" autocomplete="off" />
            <%= if @suggestions != [] do %>
              <ul class="absolute left-0 top-full w-full bg-white border rounded shadow z-10">
                <%= for suggestion <- @suggestions do %>
                  <li>
                    <button type="button" phx-click="select_suggestion" phx-value-id={suggestion.id} class="block w-full text-left px-3 py-2 hover:bg-gray-100">
                      <%= suggestion.label %>
                    </button>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </form>
        </div>
        <div id="map" phx-hook="Map" class="w-full h-[500px] rounded shadow"
          phx-update="ignore"
          data-murals={Jason.encode!(@murals)}></div>
        <div class="mt-8">
          <h2 class="text-xl font-semibold mb-2">Murais</h2>
          <ul>
            <%= for mural <- @murals do %>
              <li class="mb-2">
                <strong><%= mural.title %></strong> - <%= mural.location %>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    suggestions =
      socket.assigns.murals
      |> Enum.filter(fn mural ->
        String.contains?(String.downcase(mural.title), String.downcase(query)) or
          String.contains?(String.downcase(mural.description), String.downcase(query))
      end)
      |> Enum.map(&%{id: &1.id, label: &1.title})

    {:noreply, assign(socket, search_query: query, suggestions: suggestions)}
  end

  def handle_event("select_suggestion", %{"id" => id}, socket) do
    mural = Enum.find(socket.assigns.murals, &(&1.id == String.to_integer(id)))
    # Aqui você pode centralizar o pin no mapa e abrir o menu lateral
    {:noreply, assign(socket, search_query: mural.title, suggestions: [])}
  end
end
