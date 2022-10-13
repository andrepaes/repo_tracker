defmodule RepoTracker.Providers do
  @moduledoc """
  This module defines an api to interact with any repository on any integrated provider
  """

  @type repo :: String.t()
  @type owner :: String.t()
  @type providers :: [:github]
  @type error :: %{message: String.t(), code: non_neg_integer()}

  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.GithubImpl

  @spec list_issues(providers(), owner(), repo()) :: {:ok, [IssueResponse.t()]} | {:error, error()}
  def list_issues(provider, owner, repo) do
    impl(provider).list_issues(owner, repo)
  end

  defp impl(:github) do
    GithubImpl
  end
end
