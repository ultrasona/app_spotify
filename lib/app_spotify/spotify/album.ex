defmodule AppSpotify.Spotify.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :name, :string
    field :release_date, :date

    belongs_to :artist, AppSpotify.Spotify.Artist

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:name, :release_date])
    |> validate_required([:name, :release_date])
    |> assoc_constraint(:artist)
  end
end
