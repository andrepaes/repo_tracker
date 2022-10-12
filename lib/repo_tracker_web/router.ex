defmodule RepoTrackerWeb.Router do
  use RepoTrackerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RepoTrackerWeb do
    pipe_through :api
  end
end
