defmodule RepoTracker.Repositories do
  @moduledoc """
  Module reponsible to provide an api to work with repositories including cross-context functionalities
  """

  alias RepoTracker.Repo
  alias RepoTracker.Providers
  alias RepoTracker.Workers.RepoFetcher
  alias RepoTracker.Workers.Replies
  alias Ecto.Multi

  @spec track_repository(
          Providers.provider(),
          Providers.login(),
          Providers.repo(),
          webhook_target :: String.t(),
          opts :: Keyword.t()
        ) :: :ok | {:error, Oban.Job.changeset() | term()}
  def track_repository(provider, owner, repo_name, webhook_target, opts \\ []) do
    schedule_in = Keyword.get(opts, :schedule_in, {1, :second})

    repo_fetcher_job = RepoFetcher.new(%{provider: provider, login: owner, repo_name: repo_name})

    replies_job =
      Replies.new(%{target: webhook_target, owner_login: owner, repo_name: repo_name},
        schedule_in: schedule_in
      )

    jobs =
      Multi.new()
      |> Oban.insert(:insert_repo_fetcher_job, repo_fetcher_job)
      |> Oban.insert(:insert_replies_job, replies_job)
      |> Repo.transaction()

    case jobs do
      {:ok, _} -> :ok
      {:error, _, error, _} -> {:error, error}
    end
  end
end
