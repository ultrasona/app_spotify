defmodule AppSpotifyWeb.AlbumController do
use AppSpotifyWeb, :controller

alias AppSpotify.Spotify

  def list_by_artist(conn, %{"artist_name" => artist_name}) do
    with {:ok, token} <- AppSpotify.Spotify.get_access_token,
      result <-  Spotify.get_albums_by_artist_name(token, artist_name) do
        albums =
          Enum.map(result, fn album ->
            %{
              name: album.name,
              release_date: album.release_date
            }
          end)
        json(conn, albums)
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: reason})
    end
  end
end
