ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(AppSpotify.Repo, :manual)
Mox.defmock(AppSpotify.SpotifyMock, for: AppSpotify.SpotifyBehaviour)
