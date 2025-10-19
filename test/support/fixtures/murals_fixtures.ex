defmodule ArtMaps.MuralsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ArtMaps.Murals` context.
  """

  @doc """
  Generate a mural.
  """
  def mural_fixture(attrs \\ %{}) do
    {:ok, mural} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image_url: "some image_url",
        latitude: 120.5,
        longitude: 120.5,
        title: "some title"
      })
      |> ArtMaps.Murals.create_mural()

    mural
  end
end
