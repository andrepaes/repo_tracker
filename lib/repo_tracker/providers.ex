defmodule RepoTracker.Providers do
  @moduledoc """
  This module defines an api to interact with any repository on any integrated provider
  """

  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.GithubImpl
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.UserResponse

  @type repo :: String.t()
  @type login :: String.t()
  @type provider :: :github
  @type error :: %{message: String.t(), code: non_neg_integer()}
  @type repo_info :: %{
          required(:issues) => [IssueResponse.t()],
          required(:contributors) => [ContributorResponse.t()]
        }

  @spec fetch_repo_info(provider(), login(), repo()) ::
          {:ok, repo_info()} | {:error, error()}
  def fetch_repo_info(provider, login, repo_name) do
    with {:ok, issues} <- list_issues(provider, login, repo_name),
         {:ok, contributors} <- list_contributors(provider, login, repo_name) do
      {:ok, %{issues: issues, contributors: contributors}}
    end
  end

  @spec list_issues(provider(), login(), repo()) :: {:ok, [IssueResponse.t()]} | {:error, error()}
  def list_issues(provider, login, repo) do
    impl(provider).list_issues(login, repo)
  end

  @spec list_contributors(provider(), login(), repo()) ::
          {:ok, [ContributorResponse.t()]} | {:error, error()}
  def list_contributors(provider, login, repo) do
    impl(provider).list_contributors(login, repo)
  end

  @spec get_user(provider(), login()) :: {:ok, UserResponse.t()} | {:error, error()}
  def get_user(provider, login) do
    impl(provider).get_user(login)
  end

  defp impl(provider) do
    Application.get_env(:repo_tracker, :providers, %{github: GithubImpl})[provider]
  end
end
