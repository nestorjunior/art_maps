defmodule ArtMaps.Murals.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :photo_url, :bio, :website, :instagram, :contact]}

  schema "artists" do
    field :name, :string
    field :photo_url, :string
    field :bio, :string
    field :website, :string
    field :instagram, :string
    field :contact, :string

    has_many :murals, ArtMaps.Murals.Mural

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :photo_url, :bio, :website, :instagram, :contact])
    |> validate_required([:name])
  end
end
