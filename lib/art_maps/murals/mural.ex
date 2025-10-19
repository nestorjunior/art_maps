defmodule ArtMaps.Murals.Mural do
  use Ecto.Schema
  import Ecto.Changeset

  schema "murals" do
    field :title, :string
    field :description, :string
    field :latitude, :float
    field :longitude, :float
    field :image_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mural, attrs) do
    mural
    |> cast(attrs, [:title, :description, :latitude, :longitude, :image_url])
    |> validate_required([:title, :description, :latitude, :longitude, :image_url])
  end
end
