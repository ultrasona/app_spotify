defmodule AppSpotify.Spotify.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artists" do
    field :name, :string
    field :spotify_id, :string

    has_many :albums, AppSpotify.Spotify.Album

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :spotify_id])
    |> validate_required([:name, :spotify_id])
    |> unique_constraint(:spotify_id)
  end
end
