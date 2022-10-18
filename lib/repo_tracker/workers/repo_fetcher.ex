defmodule RepoTracker.Workers.RepoFetcher do
  @moduledoc """
  Worker responsible for fetch de general repo information as issues and contributors
  """
  use Oban.Worker

  alias RepoTracker.Contribution
  alias RepoTracker.Providers
  alias RepoTracker.Repo
  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Users.User
  alias RepoTracker.Workers.UsersFetcher

  alias Ecto.Multi

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"repo_name" => repo_name, "login" => login, "provider" => provider}
      }) do
    provider = String.to_existing_atom(provider)

    with {:ok, issues} <- Providers.list_issues(provider, login, repo_name),
         {:ok, contributors} <- Providers.list_contributors(provider, login, repo_name) do
      all_contributors =
        Enum.reduce(contributors, %{}, fn %{login: login} = contributor, acc ->
          Map.put(acc, login, remove_struct(contributor))
        end)

      insertable_contributors =
        all_contributors
        |> Map.values()
        |> Enum.map(&Map.drop(&1, [:commits_quantity]))

      Multi.new()
      |> Multi.run(:insert_owner, &insert_owner(&1, &2, login))
      |> Multi.insert_all(
        :insert_contributors,
        User,
        insertable_contributors,
        on_conflict: :nothing,
        returning: true
      )
      |> Multi.run(
        :insert_repository,
        &insert_repository(&1, &2, issues, repo_name)
      )
      |> Multi.run(:insert_contributions, &insert_contributions(&1, &2, all_contributors))
      |> Multi.run(:enqueue_users_fetcher, &enqueue_users_fetcher/2)
      |> Repo.transaction()
    end
    :ok
  end

  defp insert_owner(_repo, _, login) do
    case Repo.get_by(User, login: login) do
      nil -> %User{}
      user -> user
    end
    |> User.changeset(%{login: login})
    |> Repo.insert_or_update()
  end

  defp insert_repository(
         _repo,
         %{
           insert_owner: owner
         },
         issues,
         repo_name
       ) do
    case Repo.get_by(Repository, repo_name: repo_name, owner_id: owner.id) do
      nil -> %Repository{}
      repository -> repository
    end
    |> Repository.changeset(%{
      repo_name: repo_name,
      owner_id: owner.id,
      issues: remove_struct(issues)
    })
    |> Repo.insert_or_update()
  end

  defp insert_contributions(
         _repo,
         %{
           insert_contributors: {_contributors_quantity, contributors},
           insert_owner: owner,
           insert_repository: %{id: repo_id}
         },
         all_contributors
       ) do
    contributions =
      Enum.map([owner | contributors], fn %{id: contributor_id, login: login} ->
        contribution = Map.fetch!(all_contributors, login)

        %{
          contributor_id: contributor_id,
          repository_id: repo_id,
          commits_quantity: contribution.commits_quantity
        }
      end)

    {:ok,
     Repo.insert_all(Contribution, contributions,
       on_conflict: {:replace, [:commits_quantity]},
       conflict_target: [:repository_id, :contributor_id]
     )}
  end

  defp enqueue_users_fetcher(_repo, %{insert_contributors: {_quantity_of_contributors, contributors}, insert_owner: owner}) do
    insertable_data =
      Enum.map([owner | contributors], fn contributor ->
        UsersFetcher.new(%{login: contributor.login, provider: :github})
      end)

    {:ok, Oban.insert_all(insertable_data)}
  end

  defp remove_struct(list) when is_list(list) do
    Enum.map(list, &remove_struct/1)
  end

  defp remove_struct(data) when is_struct(data) do
    Map.drop(data, [:__struct__, :__meta__])
  end
end
