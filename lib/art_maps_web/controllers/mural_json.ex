defmodule ArtMapsWeb.MuralJSON do
  alias ArtMaps.Murals.Mural

  @doc """
  Renders a list of murals.
  """
  def index(%{murals: murals}) do
    %{data: for(mural <- murals, do: data(mural))}
  end

  @doc """
  Renders a single mural.
  """
  def show(%{mural: mural}) do
    %{data: data(mural)}
  end

  defp data(%Mural{} = mural) do
    %{
      id: mural.id,
      title: mural.title,
      description: mural.description,
      latitude: mural.latitude,
      longitude: mural.longitude,
      image_url: mural.image_url
    }
  end
end
