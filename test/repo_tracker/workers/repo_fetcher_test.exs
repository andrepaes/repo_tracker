defmodule RepoTracker.Workers.RepoFetcherTest do
  use RepoTracker.DataCase, async: true
  import Mox

  setup :verify_on_exit!

  alias RepoTracker.Workers.RepoFetcher

  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse

  alias RepoTracker.Users.User
  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Contribution
  alias RepoTracker.Repo

  describe "perform/1" do
    test "when repo exists" do
      expect(GithubProvidersMock, :list_issues, fn "andrepaes", "testing" ->
        {:ok, [%IssueResponse{title: "Testing", login: "random_user_1", labels: ["test", "bug"]}]}
      end)

      expect(GithubProvidersMock, :list_contributors, fn "andrepaes", "testing" ->
        {:ok,
         [
           %ContributorResponse{login: "andrepaes", commits_quantity: 400},
           %ContributorResponse{login: "contributor_1", commits_quantity: 202}
         ]}
      end)

      {:ok, %{insert_repository: %{id: repo_id}}} =
        RepoFetcher.perform(%Oban.Job{
          args: %{"repo_name" => "testing", "login" => "andrepaes", "provider" => "github"}
        })

      assert [
               %{login: "andrepaes", id: contributor_id},
               %{login: "contributor_1", id: contributor_1_id}
             ] = User |> order_by(asc: :login) |> Repo.all()

      assert %{
               issues: [
                 %{title: "Testing", login: "random_user_1", labels: ["test", "bug"]}
               ]
             } = Repo.get(Repository, repo_id)

      assert [
               %{repository_id: ^repo_id, contributor_id: ^contributor_id, commits_quantity: 400},
               %{
                 repository_id: ^repo_id,
                 contributor_id: ^contributor_1_id,
                 commits_quantity: 202
               }
             ] = Repo.all(Contribution)
    end

    test "when repo don't exists" do
      expect(GithubProvidersMock, :list_issues, fn "andrepaes", "testing" ->
        {:error, %{code: 404}}
      end)

      {:error, %{code: 404}}

      RepoFetcher.perform(%Oban.Job{
        args: %{"repo_name" => "testing", "login" => "andrepaes", "provider" => "github"}
      })

      assert [] == User |> order_by(asc: :login) |> Repo.all()
    end
  end
end
