defmodule AppSpotifyWeb.Router do
  use AppSpotifyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", AppSpotifyWeb do
    pipe_through :api

    get "/albums", AlbumController, :list_by_artist
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app_spotify, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
   # import Phoenix.LiveDashboard.Router
  end
end
