defmodule RepoTrackerWeb.RepositoriesController do
  use RepoTrackerWeb, :controller

  alias RepoTracker

  action_fallback GeolocationApiWeb.FallbackController

  def track(conn, %{"repo_name" => repo_name, "user_name" => user_name, "target" => target}) do
    with :ok <- RepoTracker.track_repository(:github, user_name, repo_name, target) do
      conn
      |> json(%{"message" => "Your request is being processed"})
    end
  end
end
