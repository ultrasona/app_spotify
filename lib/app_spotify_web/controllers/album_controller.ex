defmodule AppSpotifyWeb.AlbumController do
use AppSpotifyWeb, :controller

alias AppSpotify.Spotify

  def list_by_artist(conn, %{"artist_name" => artist_name}) do
    with {:ok, token} <- AppSpotify.Spotify.get_access_token,
      result <-  Spotify.get_artist_by_name(token, artist_name) do
        IO.puts("YEEEEEAH")
        Spotify.get_albums_by_artist_name(token, result)
        json(conn, result)
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: reason})
    end

    # get artist from spotify and save it or from bdd directly


    # from artist get album

    # case Spotify.get_albums_by_artist_name(access_token, artist_name) do
    #   {:ok, result} ->
    #     json(conn, result)

    #   {:error, :not_found} ->
    #     conn
    #     |> put_status(:not_found)
    #     |> json(%{error: %{code: 404, message: "Artist not found"}})

    #   {:error, :internal_error} ->
    #     conn
    #     |> put_status(:internal_server_error)
    #     |> json(%{error: %{code: 500, message: "Internal server error"}})
    # end
  end
end
