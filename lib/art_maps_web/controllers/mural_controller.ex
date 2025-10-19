defmodule ArtMapsWeb.MuralController do
  use ArtMapsWeb, :controller

  alias ArtMaps.Murals
  alias ArtMaps.Murals.Mural

  action_fallback ArtMapsWeb.FallbackController

  def index(conn, _params) do
    murals = Murals.list_murals()
    render(conn, :index, murals: murals)
  end

  def create(conn, %{"mural" => mural_params}) do
    with {:ok, %Mural{} = mural} <- Murals.create_mural(mural_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/murals/#{mural}")
      |> render(:show, mural: mural)
    end
  end

  def show(conn, %{"id" => id}) do
    mural = Murals.get_mural!(id)
    render(conn, :show, mural: mural)
  end

  def update(conn, %{"id" => id, "mural" => mural_params}) do
    mural = Murals.get_mural!(id)

    with {:ok, %Mural{} = mural} <- Murals.update_mural(mural, mural_params) do
      render(conn, :show, mural: mural)
    end
  end

  def delete(conn, %{"id" => id}) do
    mural = Murals.get_mural!(id)

    with {:ok, %Mural{}} <- Murals.delete_mural(mural) do
      send_resp(conn, :no_content, "")
    end
  end
end
