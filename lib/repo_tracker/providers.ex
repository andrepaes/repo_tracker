defmodule RepoTracker.Providers do
  @moduledoc """
  This module defines an api to interact with any repository on any integrated provider
  """

  @type repo :: String.t()
  @type owner :: String.t()
  @type login :: String.t()
  @type provider :: :github
  @type error :: %{message: String.t(), code: non_neg_integer()}
  @type repo_info :: %{
          required(:issues) => [IssueResponse.t()],
          required(:contributors) => [ContributorResponse.t()]
        }

  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.UserResponse
  alias RepoTracker.Providers.GithubImpl

  @spec fetch_repo_info(Providers.provider(), Providers.login(), Providers.repo()) ::
          {:ok, repo_info()} | {:error, error()}
  def fetch_repo_info(provider, login, repo_name) do
    with {:ok, issues} <- list_issues(provider, login, repo_name),
         {:ok, contributors} <- list_contributors(provider, login, repo_name) do
      {:ok, %{issues: issues, contributors: contributors}}
    end
  end

  @spec list_issues(provider(), owner(), repo()) :: {:ok, [IssueResponse.t()]} | {:error, error()}
  def list_issues(provider, owner, repo) do
    impl(provider).list_issues(owner, repo)
  end

  @spec list_contributors(provider(), owner(), repo()) ::
          {:ok, [ContributorResponse.t()]} | {:error, error()}
  def list_contributors(provider, owner, repo) do
    impl(provider).list_contributors(owner, repo)
  end

  @spec get_user(provider(), login()) :: {:ok, UserResponse.t()} | {:error, error()}
  def get_user(provider, login) do
    impl(provider).get_user(login)
  end

  defp impl(:github) do
    GithubImpl
  end
end
