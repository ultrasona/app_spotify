defmodule AppSpotify.SpotifyBehaviour do
  @callback get_access_token() :: {:ok, String.t()} | {:error, String.t()}
  @callback get_albums_for_artist(String.t(), String.t()) :: list()
end
