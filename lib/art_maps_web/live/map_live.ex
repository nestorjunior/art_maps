defmodule ArtMapsWeb.MapLive do
  use ArtMapsWeb, :live_view

  alias ArtMaps.Murals

  @impl true
  def mount(_params, _session, socket) do
    murals = Murals.list_murals() |> ArtMaps.Repo.preload(:artist)
    current_user = if socket.assigns[:current_scope], do: socket.assigns.current_scope.user, else: nil

    {:ok,
     socket
     |> assign(:murals, murals)
     |> assign(:selected_mural, nil)
     |> assign(:page_title, "Mapa de Murais Urbanos")
     |> assign(:search_query, "")
     |> assign(:suggestions, [])
     |> assign(:current_user, current_user)
     |> assign(:show_add_pin_modal, false)
     |> assign(:active_tab, "mural")
     |> assign(:new_pin_lat, nil)
     |> assign(:new_pin_lng, nil)
     |> assign_form(to_form(%{}, as: :mural))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative w-full h-screen flex">
      <!-- Modal de adicionar pin -->
      <%= if @show_add_pin_modal do %>
        <.add_pin_modal form={@form} lat={@new_pin_lat} lng={@new_pin_lng} />
      <% end %>

      <!-- Modal lateral à esquerda -->
      <%= if @selected_mural do %>
        <.mural_modal mural={@selected_mural} active_tab={@active_tab} current_user={@current_user} />
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

        <!-- Botão de adicionar pin (apenas para usuários aprovados) -->
        <%= if @current_user && @current_user.approved do %>
          <button
            phx-click="open_add_pin_modal"
            class="absolute bottom-8 right-8 z-20 bg-blue-500 text-white px-6 py-3 rounded-full shadow-lg hover:bg-blue-600 font-semibold"
          >
            📍 Adicionar Mural
          </button>
        <% end %>

        <div id="map" phx-hook="Map" class="flex-1 w-full"
          phx-update="ignore"
          data-murals={Jason.encode!(@murals)}></div>
      </div>
    </div>
    """
  end

  # Componente da modal de adicionar pin
  attr :form, :map, required: true
  attr :lat, :any, default: nil
  attr :lng, :any, default: nil

  def add_pin_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black bg-opacity-50 z-40 flex items-center justify-center">
      <div class="bg-white rounded-lg shadow-2xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center p-6 border-b">
          <h2 class="text-2xl font-bold text-gray-900">📍 Adicionar Novo Mural</h2>
          <button phx-click="close_add_pin_modal" class="text-2xl text-gray-600 hover:text-gray-900">&times;</button>
        </div>

        <.form for={@form} phx-submit="save_pin" class="p-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Título do Mural</label>
            <input
              type="text"
              name="mural[title]"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              placeholder="Ex: Mural das Etnias"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Descrição</label>
            <textarea
              name="mural[description]"
              rows="4"
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              placeholder="Descreva o mural, sua história, localização..."
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL da Imagem</label>
            <input
              type="url"
              name="mural[image_url]"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              placeholder="https://exemplo.com/imagem.jpg"
            />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Latitude</label>
              <input
                type="number"
                step="any"
                name="mural[latitude]"
                value={@lat}
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                placeholder="-23.5505"
              />
              <p class="text-xs text-gray-500 mt-1">Clique no mapa para selecionar</p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Longitude</label>
              <input
                type="number"
                step="any"
                name="mural[longitude]"
                value={@lng}
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                placeholder="-46.6333"
              />
              <p class="text-xs text-gray-500 mt-1">Clique no mapa para selecionar</p>
            </div>
          </div>

          <div class="flex gap-3 pt-4">
            <button
              type="button"
              phx-click="close_add_pin_modal"
              class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="flex-1 px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
            >
              Salvar Mural
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  # Componente da modal lateral
  attr :mural, :map, required: true
  attr :active_tab, :string, default: "mural"
  attr :current_user, :map, default: nil

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
        <button
          phx-click="change_tab"
          phx-value-tab="mural"
          class={"flex-1 py-3 #{if @active_tab == "mural", do: "border-b-2 border-blue-500 font-semibold text-gray-900", else: "text-gray-500 hover:text-gray-800"}"}
        >
          🖼️ Mural
        </button>
        <button
          phx-click="change_tab"
          phx-value-tab="artist"
          class={"flex-1 py-3 #{if @active_tab == "artist", do: "border-b-2 border-blue-500 font-semibold text-gray-900", else: "text-gray-500 hover:text-gray-800"}"}
        >
          🎨 Artista
        </button>
        <%= if @current_user do %>
          <button
            phx-click="change_tab"
            phx-value-tab="my_murals"
            class={"flex-1 py-3 #{if @active_tab == "my_murals", do: "border-b-2 border-blue-500 font-semibold text-gray-900", else: "text-gray-500 hover:text-gray-800"}"}
          >
            📁 Meus
          </button>
        <% end %>
      </div>

      <!-- Conteúdo da modal -->
      <div class="flex-1 p-4 overflow-y-auto">
        <%= case @active_tab do %>
          <% "mural" -> %>
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

          <% "artist" -> %>
            <%= if @mural.artist do %>
              <!-- Foto do artista -->
              <%= if @mural.artist.photo_url do %>
                <img src={@mural.artist.photo_url} alt={@mural.artist.name} class="w-32 h-32 rounded-full mx-auto mb-4 object-cover" />
              <% end %>

              <h3 class="text-2xl font-bold text-gray-900 mb-2 text-center"><%= @mural.artist.name %></h3>

              <%= if @mural.artist.bio do %>
                <p class="text-gray-800 mb-4 leading-relaxed"><%= @mural.artist.bio %></p>
              <% end %>

              <div class="space-y-2">
                <%= if @mural.artist.instagram do %>
                  <p class="text-gray-700"><strong>Instagram:</strong> <%= @mural.artist.instagram %></p>
                <% end %>
                <%= if @mural.artist.website do %>
                  <p class="text-gray-700">
                    <strong>Website:</strong>
                    <a href={@mural.artist.website} target="_blank" class="text-blue-500 hover:underline">
                      <%= @mural.artist.website %>
                    </a>
                  </p>
                <% end %>
                <%= if @mural.artist.contact do %>
                  <p class="text-gray-700"><strong>Contato:</strong> <%= @mural.artist.contact %></p>
                <% end %>
              </div>
            <% else %>
              <p class="text-gray-600 italic">Informações do artista não disponíveis.</p>
            <% end %>

          <% "my_murals" -> %>
            <h3 class="text-xl font-bold text-gray-900 mb-4">Meus Murais Cadastrados</h3>
            <p class="text-gray-600 mb-4">Em breve você verá aqui todos os murais que cadastrou.</p>
        <% end %>
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
    {:noreply, assign(socket, selected_mural: nil, active_tab: "mural")}
  end

  def handle_event("mural-selected", %{"id" => id}, socket) do
    mural = Enum.find(socket.assigns.murals, &(&1.id == id))

    if mural do
      {:noreply, assign(socket, selected_mural: mural, active_tab: "mural")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
  end

  def handle_event("open_add_pin_modal", _params, socket) do
    {:noreply, assign(socket, show_add_pin_modal: true)}
  end

  def handle_event("close_add_pin_modal", _params, socket) do
    {:noreply, assign(socket, show_add_pin_modal: false, new_pin_lat: nil, new_pin_lng: nil)}
  end

  def handle_event("map-clicked", %{"lat" => lat, "lng" => lng}, socket) do
    if socket.assigns.show_add_pin_modal do
      {:noreply, assign(socket, new_pin_lat: lat, new_pin_lng: lng)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("save_pin", %{"mural" => mural_params}, socket) do
    current_user = socket.assigns.current_user

    if current_user && current_user.approved do
      # Adicionar user_id aos parâmetros
      mural_params = Map.put(mural_params, "user_id", current_user.id)

      case Murals.create_mural(mural_params) do
        {:ok, _mural} ->
          # Recarregar murais com o novo
          murals = Murals.list_murals() |> ArtMaps.Repo.preload(:artist)

          {:noreply,
           socket
           |> assign(:murals, murals)
           |> assign(:show_add_pin_modal, false)
           |> assign(:new_pin_lat, nil)
           |> assign(:new_pin_lng, nil)
           |> put_flash(:info, "Mural adicionado com sucesso!")}

        {:error, changeset} ->
          {:noreply,
           socket
           |> assign_form(to_form(changeset, as: :mural))
           |> put_flash(:error, "Erro ao adicionar mural. Verifique os campos.")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Você precisa ser aprovado pelo admin para adicionar murais.")}
    end
  end

  defp assign_form(socket, form) do
    assign(socket, :form, form)
  end
end
