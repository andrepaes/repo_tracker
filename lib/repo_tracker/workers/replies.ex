defmodule RepoTracker.Workers.Replies do
  @moduledoc """
  Worker responsible for get the info back to the user through webhook
  """
  use Oban.Worker

  import Ecto.Query

  alias RepoTracker.Notifiers
  alias RepoTracker.Repo
  alias RepoTracker.Repositories.Repository

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        id: job_id,
        args: %{"target" => target, "owner_login" => login, "repo_name" => repo_name}
      }) do
    response =
      case fetch_repo_info(login, repo_name) do
        nil ->
          Notifiers.notify(
            :webhook,
            target,
            Jason.encode!(%{message: "Can't fetch repository information"})
          )

        repo_info ->
          data_to_send = %{
            user: repo_info.owner.full_name,
            repository: repo_info.repo_name,
            issues: extract_issues(repo_info),
            contributors: extract_contributors(repo_info)
          }

          Notifiers.notify(:webhook, target, Jason.encode!(data_to_send))
      end

    case response do
      {:ok, %{reason: :nxdomain}} ->
        Logger.error("Job #{inspect(job_id)} was skipped because: Target(#{target}) don't exists")
        :ok

      resp ->
        resp
    end
  end

  def fetch_repo_info(login, repo_name) do
    query =
      from r in Repository,
        join: o in assoc(r, :owner),
        left_join: c in assoc(r, :contributions),
        left_join: co in assoc(c, :contributor),
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
        {full_name, login, commits_quantity}
        |> Tuple.to_list()
        |> Enum.join(",")
    end)
  end

  defp extract_issues(%{issues: issues}) do
    Enum.map(issues, fn %{title: title, login: login, labels: labels} ->
      {title, login, labels}
      |> Tuple.to_list()
      |> Enum.join(",")
    end)
  end
end
