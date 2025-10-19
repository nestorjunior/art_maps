defmodule ArtMaps.Murals.Mural do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title, :description, :latitude, :longitude, :image_url, :artist_id, :artist]}

  schema "murals" do
    field(:title, :string)
    field(:description, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:image_url, :string)

    belongs_to(:artist, ArtMaps.Murals.Artist)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mural, attrs) do
    mural
    |> cast(attrs, [:title, :description, :latitude, :longitude, :image_url, :artist_id])
    |> validate_required([:title, :description, :latitude, :longitude])
  end
end
