defmodule ArtMapsWeb.AdminLive.Users do
  use ArtMapsWeb, :live_view

  alias ArtMaps.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Gerenciar Usuários")
     |> assign(:pending_users, Accounts.list_pending_users())
     |> assign(:all_users, Accounts.list_users())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Gerenciar Usuários</h1>

      <!-- Usuários Pendentes -->
      <div class="mb-12">
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">
          Usuários Aguardando Aprovação
          <span class="text-sm text-gray-500">(<%= length(@pending_users) %>)</span>
        </h2>

        <%= if @pending_users == [] do %>
          <p class="text-gray-600 italic">Nenhum usuário pendente de aprovação.</p>
        <% else %>
          <div class="bg-white shadow-md rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Nome
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Cadastrado em
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for user <- @pending_users do %>
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <%= user.email %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <%= user.full_name || "-" %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <%= Calendar.strftime(user.inserted_at, "%d/%m/%Y %H:%M") %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button
                        phx-click="approve"
                        phx-value-id={user.id}
                        class="text-green-600 hover:text-green-900 mr-3"
                      >
                        ✓ Aprovar
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>

      <!-- Todos os Usuários -->
      <div>
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">
          Todos os Usuários
          <span class="text-sm text-gray-500">(<%= length(@all_users) %>)</span>
        </h2>

        <div class="bg-white shadow-md rounded-lg overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Email
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Nome
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Papel
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Status
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for user <- @all_users do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <%= user.email %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <%= user.full_name || "-" %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span class={"px-2 py-1 rounded text-xs font-semibold #{if user.role == "admin", do: "bg-purple-100 text-purple-800", else: "bg-gray-100 text-gray-800"}"}>
                      <%= user.role %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span class={"px-2 py-1 rounded text-xs font-semibold #{if user.approved, do: "bg-green-100 text-green-800", else: "bg-yellow-100 text-yellow-800"}"}>
                      <%= if user.approved, do: "Aprovado", else: "Pendente" %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <%= if !user.approved do %>
                      <button
                        phx-click="approve"
                        phx-value-id={user.id}
                        class="text-green-600 hover:text-green-900 mr-3"
                      >
                        ✓ Aprovar
                      </button>
                    <% else %>
                      <button
                        phx-click="unapprove"
                        phx-value-id={user.id}
                        class="text-yellow-600 hover:text-yellow-900 mr-3"
                      >
                        ⊘ Desaprovar
                      </button>
                    <% end %>

                    <%= if user.role != "admin" do %>
                      <button
                        phx-click="make_admin"
                        phx-value-id={user.id}
                        class="text-purple-600 hover:text-purple-900"
                      >
                        ⬆ Tornar Admin
                      </button>
                    <% end %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>

      <div class="mt-8">
        <.link href="/" class="text-blue-600 hover:text-blue-800">
          ← Voltar ao Mapa
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.approve_user(user)

    {:noreply,
     socket
     |> put_flash(:info, "Usuário aprovado com sucesso!")
     |> assign(:pending_users, Accounts.list_pending_users())
     |> assign(:all_users, Accounts.list_users())}
  end

  def handle_event("unapprove", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.unapprove_user(user)

    {:noreply,
     socket
     |> put_flash(:info, "Usuário desaprovado.")
     |> assign(:pending_users, Accounts.list_pending_users())
     |> assign(:all_users, Accounts.list_users())}
  end

  def handle_event("make_admin", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.make_admin(user)

    {:noreply,
     socket
     |> put_flash(:info, "Usuário promovido a administrador!")
     |> assign(:all_users, Accounts.list_users())}
  end
end
