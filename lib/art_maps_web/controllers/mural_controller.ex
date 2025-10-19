defmodule ArtMapsWeb.MuralController do
  use ArtMapsWeb, :controller

  alias ArtMaps.Murals
  alias ArtMaps.Murals.Mural

  plug(:put_root_layout, {ArtMapsWeb.Layouts, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case Murals.paginate_murals(params) do
      {:ok, assigns} ->
        render(conn, :index, assigns)

      {:error, error} ->
        conn
        |> put_flash(:error, "There was an error rendering Murals. #{inspect(error)}")
        |> redirect(to: ~p"/admin/murals")
    end
  end

  def new(conn, _params) do
    changeset = Murals.change_mural(%Mural{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"mural" => mural_params}) do
    case Murals.create_mural(mural_params) do
      {:ok, mural} ->
        conn
        |> put_flash(:info, "Mural created successfully.")
        |> redirect(to: ~p"/admin/murals/#{mural}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mural = Murals.get_mural!(id)
    render(conn, :show, mural: mural)
  end

  def edit(conn, %{"id" => id}) do
    mural = Murals.get_mural!(id)
    changeset = Murals.change_mural(mural)
    render(conn, :edit, mural: mural, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mural" => mural_params}) do
    mural = Murals.get_mural!(id)

    case Murals.update_mural(mural, mural_params) do
      {:ok, mural} ->
        conn
        |> put_flash(:info, "Mural updated successfully.")
        |> redirect(to: ~p"/admin/murals/#{mural}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, mural: mural, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mural = Murals.get_mural!(id)
    {:ok, _mural} = Murals.delete_mural(mural)

    conn
    |> put_flash(:info, "Mural deleted successfully.")
    |> redirect(to: ~p"/admin/murals")
  end
end
