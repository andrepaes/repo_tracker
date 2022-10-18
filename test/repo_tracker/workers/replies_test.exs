defmodule RepoTracker.Workers.RepliesTest do
  use RepoTracker.DataCase, async: true
  use Oban.Testing, repo: RepoTracker.Repo
  import Mox
  import RepoTracker.Factory

  setup :verify_on_exit!

  alias RepoTracker.Workers.RepoFetcher

  alias RepoTracker.Contribution
  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Repo
  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Users.User

  describe "perform/1" do
    setup do
      owner = insert(:user, %{login: "andrepaes"})

      repo =
        insert(:repository, %{
          repo_name: "testing",
          owner: owner,
          issues: [
            %{title: "Testing", login: "random_user_1", labels: ["test", "bug"]},
            %{title: "Testing2", login: "random_user_2", labels: ["enhancement"]}
          ]
        })

      insert(:contribution, %{commits_quantity: 400, repository: repo, contributor: owner})
      %{repo: repo, owner: owner}
    end

    test "when repo exists", %{repo: repo, owner: owner} do
      expect(WebhookNotifiersMock, :notify, fn "google.com",
                                               "{\"contributors\":[\"Test 123,andrepaes,400\"],\"issues\":[\"Testing,random_user_1,testbug\",\"Testing2,random_user_2,enhancement\"],\"repository\":\"testing\",\"user\":\"Test 123\"}" ->
        {:ok, %{status_code: 200}}
      end)

      {:ok, %{status_code: 200}} =
        RepoTracker.Workers.Replies.perform(%Oban.Job{
          args: %{
            "target" => "google.com",
            "owner_login" => owner.login,
            "repo_name" => repo.repo_name
          }
        })
    end

    test "when repo don't exists", %{repo: repo, owner: owner} do
      expect(WebhookNotifiersMock, :notify, fn "non_existent_url.com", _ ->
        {:ok, %{reason: :nxdomain}}
      end)

      :ok =
        RepoTracker.Workers.Replies.perform(%Oban.Job{
          args: %{
            "target" => "non_existent_url.com",
            "owner_login" => owner.login,
            "repo_name" => repo.repo_name
          }
        })
    end
  end
end
