defmodule ArtMaps.Repo do
  use Ecto.Repo,
    otp_app: :art_maps,
    adapter: Ecto.Adapters.Postgres
end
