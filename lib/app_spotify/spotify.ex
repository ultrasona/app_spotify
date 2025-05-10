defmodule AppSpotify.Spotify do
  import Ecto.Query, warn: false
  alias AppSpotify.Repo

  alias AppSpotify.Spotify.Artist

  @behaviour AppSpotify.SpotifyBehaviour
  @spotify_client Application.compile_env(:app_spotify, :spotify_client)

  @doc """
  Returns the list of artists.

  ## Examples

      iex> list_artists()
      [%Artist{}, ...]

  """
  def list_artists do
    Repo.all(Artist)
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

      iex> get_artist!(123)
      %Artist{}

      iex> get_artist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_artist!(id), do: Repo.get!(Artist, id)

  @doc """
  Creates a artist.

  ## Examples

      iex> create_artist(%{field: value})
      {:ok, %Artist{}}

      iex> create_artist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artist.

  ## Examples

      iex> update_artist(artist, %{field: new_value})
      {:ok, %Artist{}}

      iex> update_artist(artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artist.

  ## Examples

      iex> delete_artist(artist)
      {:ok, %Artist{}}

      iex> delete_artist(artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artist changes.

  ## Examples

      iex> change_artist(artist)
      %Ecto.Changeset{data: %Artist{}}

  """
  def change_artist(%Artist{} = artist, attrs \\ %{}) do
    Artist.changeset(artist, attrs)
  end

  alias AppSpotify.Spotify.Album

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums()
      [%Album{}, ...]

  """
  def list_albums do
    Repo.all(Album)
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(123)
      %Album{}

      iex> get_album!(456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(id), do: Repo.get!(Album, id)

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Album{} = album, attrs) do
    album
    |> Album.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a album.

  ## Examples

      iex> delete_album(album)
      {:ok, %Album{}}

      iex> delete_album(album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Album{} = album) do
    Repo.delete(album)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(album)
      %Ecto.Changeset{data: %Album{}}

  """
  def change_album(%Album{} = album, attrs \\ %{}) do
    Album.changeset(album, attrs)
  end

  def get_albums_by_artist_name(access_token, artist_name) do
    artist = get_artist_by_name(access_token, artist_name)
    albums = get_albums_by_artist(access_token, artist)

    albums
  end

  def get_artist_by_name(access_token, artist_name) do

    artist_name =
      if String.contains?(artist_name, "%") do
        String.replace(artist_name, "%", " ")
      else
        artist_name
      end

    query =
      from a in Artist,
        where: a.name == ^artist_name,
        limit: 1

    artist = Repo.one(query)

    if artist == nil do
      response = get_artist(access_token, artist_name)

      case response["artists"]["items"] do
        [first_artist | _] ->
          name = first_artist["name"]
          spotify_uri = first_artist["uri"]
          spotify_id = String.replace_prefix(spotify_uri, "spotify:artist:", "")

          result =
            %Artist{}
            |> Artist.changeset(%{name: name, spotify_id: spotify_id})
            |> Repo.insert()

          {:ok, artist} = result
          artist

        [] ->
          {:error, "No artist found in Spotify response"}
      end

    else
      artist
    end
  end

  def  get_albums_by_artist(access_token, artist) do
    query =
      from a in Album,
        where: a.artist_id == ^artist.id

    albums = Repo.all(query)

    if albums == nil || albums == [] do
      response = get_albums_for_artist(access_token, artist)

      unknown_albums =
        Enum.map(response["items"], fn album ->
          album_name = album["name"]
          #date = album["release_date"]
          date_str = album["release_date"]
          precision = album["release_date_precision"]
          id = artist.id

          date =
            case {date_str, precision} do
              {date_str, "day"} -> Date.from_iso8601!(date_str)
              {date_str, "month"} -> Date.from_iso8601!(date_str <> "-01")
              {date_str, "year"} -> Date.from_iso8601!(date_str <> "-01-01")
            end

          result =
            %Album{}
            |> Album.changeset(%{name: album_name, release_date: date, artist_id: id})
            |> Repo.insert()

          {:ok, album} = result

          album
        end)

      unknown_albums
    else
      albums
    end
  end

  def get_access_token, do: @spotify_client.get_access_token()
  def get_albums_for_artist(token, name), do: @spotify_client.get_albums_for_artist(token, name)
  def get_artist(token, name), do: @spotify_client.get_artist(token, name)
end
