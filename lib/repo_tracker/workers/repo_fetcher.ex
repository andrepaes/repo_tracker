defmodule RepoTracker.Workers.RepoFetcher do
  use Oban.Worker, queue: :events

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"repo_name" => repo_name, "login" => login}}) do
  end
end
