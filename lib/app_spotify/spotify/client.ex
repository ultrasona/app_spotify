defmodule AppSpotify.Spotify.Client do
  @behaviour AppSpotify.SpotifyBehaviour
  @spotify_token_url "https://accounts.spotify.com/api/token"
  @spotify_api "https://api.spotify.com/v1"

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

  def get_albums_for_artist(access_token, artist) do
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

  def get_artist(access_token, artist_name) do
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
