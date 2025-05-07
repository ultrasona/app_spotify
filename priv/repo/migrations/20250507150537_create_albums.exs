defmodule AppSpotify.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :name, :string, null: false
      add :release_date, :date, null: false
      add :artist_id, references(:artists, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:albums, [:artist_id])
  end
end
