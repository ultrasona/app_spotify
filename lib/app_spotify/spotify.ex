defmodule AppSpotify.Spotify do
  import Ecto.Query, warn: false
  alias AppSpotify.Repo

  alias AppSpotify.Spotify.Artist

  @spotify_token_url "https://accounts.spotify.com/api/token"
  @spotify_api "https://api.spotify.com/v1"

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

  def get_access_token do
    body = URI.encode_query(%{
      "grant_type" => "client_credentials",
      "client_id" => Application.get_env(:app_spotify, :spotify_client_id),
      "client_secret" => Application.get_env(:app_spotify, :spotify_client_secret)
    })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(@spotify_token_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)["access_token"]}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Spotify token error: #{status} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{reason}"}
    end
  end

  def get_albums_by_artist_name(access_token, artist_name) do
    artist = get_artist_by_name(access_token, artist_name)
    albums = get_albums_by_artist(access_token, artist)
    IO.inspect(albums)
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
      response = find_artist(access_token, artist_name)

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
      IO.puts("artist in db")
      IO.inspect(artist)
      artist
    end
  end

  def  get_albums_by_artist(access_token, artist) do
    query =
      from a in Album,
        where: a.artist_id == ^artist.id

    albums = Repo.all(query)

    if albums == nil || albums == [] do
      response = find_album(access_token, artist)

      unknown_albums =
        Enum.map(response["items"], fn album ->
          album_name = album["name"]
          date = album["release_date"]
          id = artist.id

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

  defp find_album(access_token, artist) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    params = URI.encode_query(%{
      "limit" => 50,
      "include_groups" => "album"
    })

    url = "#{@spotify_api}/artists/#{artist.spotify_id}/albums?#{params}"

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Spotify search error: #{status} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{reason}"}
    end
  end

  defp find_artist(access_token, artist_name) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    params = URI.encode_query(%{
      "q" => "artist:#{artist_name}",
      "type" => "artist",
      "limit" => 1
    })

    url = "#{@spotify_api}/search?#{params}"

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Spotify search error: #{status} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{reason}"}
    end
  end
end
