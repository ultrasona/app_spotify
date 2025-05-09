defmodule AppSpotify.SpotifyTest do
  use AppSpotify.DataCase

  alias AppSpotify.Spotify

  describe "artists" do
    alias AppSpotify.Spotify.Artist

    import AppSpotify.SpotifyFixtures

    @invalid_attrs %{name: nil, spotify_id: nil}

    test "list_artists/0 returns all artists" do
      artist = artist_fixture()
      assert Spotify.list_artists() == [artist]
    end

    test "get_artist!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert Spotify.get_artist!(artist.id) == artist
    end

    test "create_artist/1 with valid data creates a artist" do
      valid_attrs = %{name: "some name", spotify_id: "some spotify_id"}

      assert {:ok, %Artist{} = artist} = Spotify.create_artist(valid_attrs)
      assert artist.name == "some name"
      assert artist.spotify_id == "some spotify_id"
    end

    test "create_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spotify.create_artist(@invalid_attrs)
    end

    test "update_artist/2 with valid data updates the artist" do
      artist = artist_fixture()
      update_attrs = %{name: "some updated name", spotify_id: "some updated spotify_id"}

      assert {:ok, %Artist{} = artist} = Spotify.update_artist(artist, update_attrs)
      assert artist.name == "some updated name"
      assert artist.spotify_id == "some updated spotify_id"
    end

    test "update_artist/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = Spotify.update_artist(artist, @invalid_attrs)
      assert artist == Spotify.get_artist!(artist.id)
    end

    test "delete_artist/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = Spotify.delete_artist(artist)
      assert_raise Ecto.NoResultsError, fn -> Spotify.get_artist!(artist.id) end
    end

    test "change_artist/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = Spotify.change_artist(artist)
    end
  end

  describe "albums" do
    alias AppSpotify.Spotify.Album

    import AppSpotify.SpotifyFixtures

    @invalid_attrs %{name: nil, release_date: nil}

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Spotify.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Spotify.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      artist = artist_fixture()
      valid_attrs = %{name: "some name", release_date: ~D[2025-05-06], artist_id: artist.id}

      assert {:ok, %Album{} = album} = Spotify.create_album(valid_attrs)
      assert album.name == "some name"
      assert album.release_date == ~D[2025-05-06]
      assert album.artist_id == artist.id
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spotify.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      update_attrs = %{name: "some updated name", release_date: ~D[2025-05-07]}

      assert {:ok, %Album{} = album} = Spotify.update_album(album, update_attrs)
      assert album.name == "some updated name"
      assert album.release_date == ~D[2025-05-07]
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Spotify.update_album(album, @invalid_attrs)
      assert album == Spotify.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Spotify.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Spotify.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Spotify.change_album(album)
    end
  end
end
