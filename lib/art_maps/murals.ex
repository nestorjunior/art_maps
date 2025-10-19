defmodule ArtMaps.Murals do
  @moduledoc """
  The Murals context.
  """

  import Ecto.Query, warn: false
  alias ArtMaps.Repo

  alias ArtMaps.Murals.Mural
  alias ArtMaps.Murals.Artist

  # Artist functions
  def list_artists do
    Repo.all(Artist)
  end

  def get_artist!(id), do: Repo.get!(Artist, id)

  def get_artist_for_mural(mural) do
    if mural.artist_id do
      Repo.preload(mural, :artist).artist
    else
      nil
    end
  end

  def list_murals_by_artist(artist_id) do
    from(m in Mural, where: m.artist_id == ^artist_id, order_by: [desc: m.inserted_at])
    |> Repo.all()
  end

  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  def update_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  def delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end

  def change_artist(%Artist{} = artist, attrs \\ %{}) do
    Artist.changeset(artist, attrs)
  end

  # ...existing code...

  alias ArtMaps.Murals.Mural

  use Torch.Pagination,
    repo: ArtMaps.Repo,
    model: ArtMaps.Murals.Mural,
    name: :murals

  @doc """
  Returns the list of murals.

  ## Examples

    iex> list_murals()
    [%Mural{}, ...]

  """
  def list_murals do
  Repo.all(Mural)
  end

  @doc """
  Gets a single mural.

  Raises `Ecto.NoResultsError` if the Mural does not exist.

  ## Examples

    iex> get_mural!(123)
    %Mural{}

    iex> get_mural!(456)
    ** (Ecto.NoResultsError)

  """
  def get_mural!(id), do: Repo.get!(Mural, id)

  @doc """
  Creates a mural.

  ## Examples

    iex> create_mural(%{field: value})
    {:ok, %Mural{}}

    iex> create_mural(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  def create_mural(attrs \\ %{}) do
    %Mural{}
    |> Mural.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mural.

  ## Examples

    iex> update_mural(mural, %{field: new_value})
    {:ok, %Mural{}}

    iex> update_mural(mural, %{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  def update_mural(%Mural{} = mural, attrs) do
    mural
    |> Mural.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mural.

  ## Examples

    iex> delete_mural(mural)
    {:ok, %Mural{}}

    iex> delete_mural(mural)
    {:error, %Ecto.Changeset{}}

  """
  def delete_mural(%Mural{} = mural) do
    Repo.delete(mural)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mural changes.

  ## Examples

      iex> change_mural(mural)
      %Ecto.Changeset{source: %Mural{}}

  """
  def change_mural(%Mural{} = mural, attrs \\ %{}) do
    Mural.changeset(mural, attrs)
  end
end
