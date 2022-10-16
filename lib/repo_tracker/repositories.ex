defmodule RepoTracker.Repositories do
  @moduledoc """
  Module reponsible to provide an api to work with repositories including cross-context functionalities
  """

  alias RepoTracker.Providers
  alias RepoTracker.Workers.RepoFetcher

  @spec track_repository(Providers.provider(), Providers.owner(), Providers.repo()) ::
          {:ok, Oban.Job.t()} | {:error, Oban.Job.changeset() | term()}
  def track_repository(provider, owner, repo_name) do
    %{provider: provider, login: owner, repo_name: repo_name}
    |> RepoFetcher.new()
    |> Oban.insert()
  end
end
