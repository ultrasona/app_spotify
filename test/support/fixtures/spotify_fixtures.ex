defmodule AppSpotify.SpotifyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AppSpotify.Spotify` context.
  """

  @doc """
  Generate a artist.
  """
  def artist_fixture(attrs \\ %{}) do
    {:ok, artist} =
      attrs
      |> Enum.into(%{
        name: "some name",
        spotify_id: "some spotify_id"
      })
      |> AppSpotify.Spotify.create_artist()

    artist
  end

  @doc """
  Generate a album.
  """
  def album_fixture(attrs \\ %{}) do
    {:ok, album} =
      attrs
      |> Enum.into(%{
        name: "some name",
        release_date: ~D[2025-05-06]
      })
      |> AppSpotify.Spotify.create_album()

    album
  end
end
