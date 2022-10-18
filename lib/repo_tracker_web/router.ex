defmodule RepoTrackerWeb.Router do
  use RepoTrackerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RepoTrackerWeb do
    pipe_through :api
    post "/repositories/track", RepositoriesController, :track
  end
end
