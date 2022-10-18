defmodule RepoTracker.Workers.RepliesWorker do
  use Oban.Worker

  import Ecto.Query

  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Repo

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"target" => target, "owner_login" => login, "repo_name" => repo_name}
      }) do
    repo_info = fetch_repo_info(login, repo_name)

    data_to_send = %{
      user: repo_info.owner.full_name,
      repository: repo_info.repo_name,
      issues: extract_issues(repo_info),
      contributors: extract_contributors(repo_info)
    }

    a = HTTPoison.post(target, Jason.encode!(data_to_send))
    Logger.error("#{inspect(a)}")
  end

  def fetch_repo_info(login, repo_name) do
    query =
      from r in Repository,
        join: o in assoc(r, :owner),
        join: c in assoc(r, :contributions),
        join: co in assoc(c, :contributor),
        where: r.repo_name == ^repo_name,
        where: o.login == ^login,
        preload: [owner: o, contributions: {c, contributor: co}]

    Repo.one(query)
  end

  defp extract_contributors(%{contributions: contributions}) do
    Enum.map(contributions, fn
      %{
        commits_quantity: commits_quantity,
        contributor: %{full_name: full_name, login: login}
      } ->
        inspect({full_name, login, commits_quantity})
    end)
  end

  defp extract_issues(%{issues: issues}) do
    Enum.map(issues, fn %{title: title, login: login, labels: labels} ->
      inspect({title, login, labels})
    end)
  end
end
