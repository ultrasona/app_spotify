defmodule AppSpotify.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string, null: false
      add :spotify_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:artists, [:spotify_id])
  end
end
