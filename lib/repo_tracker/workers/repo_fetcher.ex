defmodule RepoTracker.Workers.RepoFetcher do
  use Oban.Worker

  alias RepoTracker.Providers

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"repo_name" => repo_name, "login" => login, "provider" => provider}
      }) do
    with {:ok, issues} <- Providers.list_issues(provider, login, repo_name),
         {:ok, contributors} <- Providers.list_contributors(provider, login, repo_name) do
    end
  end
end
