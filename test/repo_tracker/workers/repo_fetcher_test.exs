defmodule RepoTracker.Workers.RepoFetcherTest do
  use RepoTracker.DataCase, async: true
  use Oban.Testing, repo: RepoTracker.Repo
  import Mox
  import RepoTracker.Factory

  setup :verify_on_exit!

  alias RepoTracker.Workers.RepoFetcher

  alias RepoTracker.Contribution
  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.UserResponse
  alias RepoTracker.Repo
  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Users.User

  describe "perform/1" do
    test "when repo exists" do
      insert(:user, %{login: "andrepaes"})
      insert(:user, %{login: "contributor_1"})

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
               %{
                 repository_id: ^repo_id,
                 contributor_id: ^contributor_id,
                 commits_quantity: 400
               },
               %{
                 repository_id: ^repo_id,
                 contributor_id: ^contributor_1_id,
                 commits_quantity: 202
               }
             ] = Repo.all(Contribution)
    end

    test "updating already filled repository" do
      owner = insert(:user, %{login: "andrepaes"})

      repo =
        insert(:repository, %{
          repo_name: "testing",
          owner: owner,
          issues: [%{title: "Testing", login: "random_user_1", labels: ["test", "bug"]}]
        })

      insert(:contribution, %{commits_quantity: 400, repository: repo, contributor: owner})

      expect(GithubProvidersMock, :fetch_user, fn "contributor_1" ->
        {:ok, %UserResponse{name: "Contributor_1"}}
      end)

      expect(GithubProvidersMock, :list_issues, fn "andrepaes", "testing" ->
        {:ok,
         [
           %IssueResponse{title: "Testing", login: "random_user_1", labels: ["test", "bug"]},
           %IssueResponse{title: "Enhancement", login: "random_user_2", labels: ["enhancement"]}
         ]}
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
                 %{title: "Testing", login: "random_user_1", labels: ["test", "bug"]},
                 %{title: "Enhancement", login: "random_user_2", labels: ["enhancement"]}
               ]
             } = Repo.get(Repository, repo_id)

      assert [
               %{
                 repository_id: ^repo_id,
                 contributor_id: ^contributor_id,
                 commits_quantity: 400
               },
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

      assert [] == Repo.all(Repository)

      assert [] == Repo.all(Contribution)
    end
  end
end
