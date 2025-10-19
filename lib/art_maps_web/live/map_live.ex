defmodule ArtMapsWeb.MapLive do
  use ArtMapsWeb, :live_view

  alias ArtMaps.Murals

  @impl true
  def mount(_params, _session, socket) do
    murals = Murals.list_murals() |> ArtMaps.Repo.preload(:artist)

    {:ok,
     socket
     |> assign(:murals, murals)
     |> assign(:selected_mural, nil)
     |> assign(:page_title, "Mapa de Murais Urbanos")
     |> assign(:search_query, "")
     |> assign(:suggestions, [])
     |> assign(:current_user, socket.assigns[:current_user])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative w-full h-screen flex">
      <!-- Modal lateral à esquerda -->
      <%= if @selected_mural do %>
        <.mural_modal mural={@selected_mural} />
      <% end %>

      <!-- Mapa -->
      <div class="flex-1 flex flex-col">
        <header class="w-full bg-white shadow flex items-center justify-between px-8 py-3 z-10">
          <div class="flex items-center gap-4">
            <.link href="/" class="font-bold text-lg text-gray-900 hover:text-gray-700">
              Art Maps
            </.link>
          </div>
          <nav class="flex gap-6 text-gray-700 items-center">
            <a href="#" class="hover:underline hover:text-gray-900">Sobre</a>
            <a href="#" class="hover:underline hover:text-gray-900">Contato</a>

            <%= if @current_user do %>
              <%= if @current_user.role == "admin" do %>
                <.link href="/admin/murals" class="hover:underline hover:text-gray-900 font-semibold">
                  Murais
                </.link>
                <.link href="/admin/users" class="hover:underline hover:text-gray-900 font-semibold">
                  Usuários
                </.link>
              <% end %>
              <.link href="/users/settings" class="hover:underline hover:text-gray-900">
                Perfil
              </.link>
              <.link
                href="/users/log-out"
                method="delete"
                class="hover:underline hover:text-gray-900"
              >
                Sair
              </.link>
            <% else %>
              <.link href="/users/register" class="hover:underline hover:text-gray-900">
                Cadastro
              </.link>
              <.link href="/users/log-in" class="hover:underline hover:text-gray-900 font-semibold">
                Entrar
              </.link>
            <% end %>
          </nav>
          <div>
            <select class="border rounded px-2 py-1 text-gray-900 bg-white">
              <option value="pt">🇧🇷 PT</option>
              <option value="en">🇺🇸 EN</option>
              <option value="es">🇪🇸 ES</option>
            </select>
          </div>
        </header>

        <div class={"absolute top-20 z-20 #{if @selected_mural, do: "left-[420px]", else: "left-4"}"}>
          <form phx-change="search" class="relative w-96">
            <input
              type="text"
              name="q"
              value={@search_query}
              placeholder="Buscar mural, artista ou cidade..."
              class="w-full px-4 py-3 border rounded-lg shadow-lg bg-white"
              autocomplete="off"
            />
            <%= if @suggestions != [] do %>
              <ul class="absolute left-0 top-full w-full bg-white border rounded-lg shadow-lg z-30 mt-1">
                <%= for suggestion <- @suggestions do %>
                  <li>
                    <button
                      type="button"
                      phx-click="select_suggestion"
                      phx-value-id={suggestion.id}
                      class="block w-full text-left px-4 py-3 hover:bg-gray-100"
                    >
                      <%= suggestion.label %>
                    </button>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </form>
        </div>

        <div id="map" phx-hook="Map" class="flex-1 w-full"
          phx-update="ignore"
          data-murals={Jason.encode!(@murals)}></div>
      </div>
    </div>
    """
  end

  # Componente da modal lateral
  attr :mural, :map, required: true

  def mural_modal(assigns) do
    ~H"""
    <aside class="w-[400px] h-screen bg-white shadow-2xl overflow-y-auto z-30 flex flex-col">
      <!-- Header com botão de fechar -->
      <div class="flex justify-between items-center p-4 border-b">
        <h2 class="text-lg font-bold text-gray-900">Detalhes</h2>
        <button phx-click="close_modal" class="text-2xl text-gray-600 hover:text-gray-900">&times;</button>
      </div>

      <!-- Abas de navegação -->
      <div class="flex border-b">
        <button class="flex-1 py-3 border-b-2 border-blue-500 font-semibold text-gray-900">🖼️ Mural</button>
        <button class="flex-1 py-3 text-gray-500 hover:text-gray-800">🎨 Artista</button>
        <button class="flex-1 py-3 text-gray-500 hover:text-gray-800">📁 Perfil</button>
      </div>

      <!-- Conteúdo da modal -->
      <div class="flex-1 p-4 overflow-y-auto">
        <!-- Imagem do mural -->
        <%= if @mural.image_url do %>
          <img src={@mural.image_url} alt={@mural.title} class="w-full rounded-lg mb-4" />
        <% end %>

        <!-- Informações do mural -->
        <h3 class="text-2xl font-bold text-gray-900 mb-2"><%= @mural.title %></h3>

        <%= if @mural.artist do %>
          <p class="text-gray-700 mb-2"><strong>Por:</strong> <%= @mural.artist.name %></p>
        <% end %>

        <p class="text-gray-800 mb-4 leading-relaxed"><%= @mural.description %></p>

        <div class="text-sm text-gray-600 mb-4">
          <p>📍 Lat: <%= Float.round(@mural.latitude, 6) %>, Lng: <%= Float.round(@mural.longitude, 6) %></p>
        </div>

        <!-- Botões de ação -->
        <div class="flex gap-2 mb-4">
          <button class="flex-1 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600">
            ❤️ Favoritar
          </button>
          <button class="flex-1 bg-gray-200 text-gray-800 py-2 px-4 rounded hover:bg-gray-300">
            🔗 Compartilhar
          </button>
        </div>

        <button class="w-full bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600">
          👁️ Ver no Street View
        </button>
      </div>
    </aside>
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

    if mural do
      {:noreply, assign(socket, selected_mural: mural, search_query: mural.title, suggestions: [])}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected_mural: nil)}
  end

  def handle_event("mural-selected", %{"id" => id}, socket) do
    mural = Enum.find(socket.assigns.murals, &(&1.id == id))

    if mural do
      {:noreply, assign(socket, selected_mural: mural)}
    else
      {:noreply, socket}
    end
  end
end
