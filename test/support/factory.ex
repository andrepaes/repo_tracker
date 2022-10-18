defmodule RepoTracker.Factory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: RepoTracker.Repo

  def user_factory do
    %RepoTracker.Users.User{
      full_name: "Test 123",
      login: "test"
    }
  end

  def repository_factory do
    %RepoTracker.Repositories.Repository{
      repo_name: "Test repo",
      owner: build(:user)
    }
  end

  def contribution_factory do
    %RepoTracker.Contribution{
      commits_quantity: 100,
      repository: build(:repository),
      contributor: build(:user)
    }
  end
end
