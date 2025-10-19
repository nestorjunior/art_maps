defmodule ArtMapsWeb.PageController do
  use ArtMapsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
