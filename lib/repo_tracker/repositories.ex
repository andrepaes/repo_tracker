defmodule RepoTracker.Repositories do
  @moduledoc """
  Module reponsible to provide an api to work with repositories including cross-context functionalities
  """

  alias RepoTracker.Providers
  alias RepoTracker.Workers.RepoFetcher
  alias RepoTracker.Workers.RepliesWorker

  @spec track_repository(
          Providers.provider(),
          Providers.login(),
          Providers.repo(),
          webhook_target :: String.t()
        ) ::
          {:ok, Oban.Job.t()} | {:error, Oban.Job.changeset() | term()}
  def track_repository(provider, owner, repo_name, webhook_target) do
    %{provider: provider, login: owner, repo_name: repo_name}
    |> RepoFetcher.new()
    |> Oban.insert()

    %{target: webhook_target, owner_login: owner, repo_name: repo_name}
    |> RepliesWorker.new()
    |> Oban.insert()
  end
end
