defmodule RepoTracker.Workers.UsersTest do
  use RepoTracker.DataCase, async: true
  import Mox
  import RepoTracker.Factory

  setup :verify_on_exit!

  alias RepoTracker.Workers.UsersFetcher

  alias RepoTracker.Providers.UserResponse
  alias RepoTracker.Repo
  alias RepoTracker.Users.User

  describe "perform/1" do
    test "when user has name on provider" do
      insert(:user, %{full_name: nil, login: "andrepaes"})

      expect(GithubProvidersMock, :fetch_user, fn "andrepaes" ->
        {:ok, %UserResponse{name: "André Testing"}}
      end)

      :ok =
        UsersFetcher.perform(%Oban.Job{
          args: %{"login" => "andrepaes", "provider" => "github"}
        })

      assert [
               %{login: "andrepaes", full_name: "André Testing"}
             ] = User |> order_by(asc: :login) |> Repo.all()
    end

    test "when user don't have a name on provider" do
      insert(:user, %{full_name: nil, login: "andrepaes"})

      expect(GithubProvidersMock, :fetch_user, fn "andrepaes" ->
        {:ok, %UserResponse{name: nil}}
      end)

      :ok =
        UsersFetcher.perform(%Oban.Job{
          args: %{"login" => "andrepaes", "provider" => "github"}
        })

      assert [
               %{login: "andrepaes", full_name: nil}
             ] = User |> order_by(asc: :login) |> Repo.all()
    end

    test "when user already have name filled" do
      insert(:user, %{full_name: "André Testing", login: "andrepaes"})

      :ok =
        UsersFetcher.perform(%Oban.Job{
          args: %{"login" => "andrepaes", "provider" => "github"}
        })

      assert [
               %{login: "andrepaes", full_name: "André Testing"}
             ] = User |> order_by(asc: :login) |> Repo.all()
    end
  end
end
