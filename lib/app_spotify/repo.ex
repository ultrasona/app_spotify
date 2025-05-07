defmodule AppSpotify.Repo do
  use Ecto.Repo,
    otp_app: :app_spotify,
    adapter: Ecto.Adapters.Postgres
end
