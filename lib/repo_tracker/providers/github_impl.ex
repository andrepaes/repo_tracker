defmodule RepoTracker.Providers.GithubImpl do
  @moduledoc """
  Github implementation
  """

  @behaviour RepoTracker.Providers.Impl

  @impl true
  def list_issues(owner, repo) do
    Tentacat.Issues.list(owner, repo)
  end
end
