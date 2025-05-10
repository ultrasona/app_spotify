defmodule AppSpotifyWeb.AlbumControllerTest do
  use AppSpotifyWeb.ConnCase
  import Mox

  test "GET /api/albums returns albums list", %{conn: conn} do
    AppSpotify.SpotifyMock
    |> expect(:get_access_token, fn -> {:ok, "fake_token"} end)
    |> expect(:get_albums_by_artist_name, fn "fake_token", "Otyken" ->
      [
        %AppSpotify.Spotify.Album{name: "Phenomenon", release_date: ~D[2023-02-24]},
        %AppSpotify.Spotify.Album{name: "Kykakacha", release_date: ~D[2021-06-17]},
        %AppSpotify.Spotify.Album{name: "Lord of Honey", release_date: ~D[2019-03-22]},
        %AppSpotify.Spotify.Album{name: "Otyken", release_date: ~D[2018-06-05]}
      ]
    end)

    response =
      conn
      |> get("/api/albums", artist_name: "Otyken")
      |> json_response(200)

    assert response == [
      %{"name" => "Phenomenon", "release_date" => "2023-02-24"},
      %{"name" => "Kykakacha", "release_date" => "2021-06-17"},
      %{"name" => "Lord of Honey", "release_date" => "2019-03-22"},
      %{"name" => "Otyken", "release_date" => "2018-06-05"}
    ]
  end

  test "GET /api/albums returns error when access token fails", %{conn: conn} do
    AppSpotify.SpotifyMock
    |> expect(:get_access_token, fn -> {:error, "invalid_client"} end)

    response =
      conn
      |> get("/api/albums", artist_name: "Radiohead")
      |> json_response(502)

    assert response == %{"error" => "invalid_client"}
  end
end
