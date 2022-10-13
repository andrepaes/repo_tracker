defmodule RepoTracker.Providers.Impl do
  @moduledoc """
  This module define the contract that every provider should implement
  """

  alias RepoTracker.Providers
  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.UserResponse

  @callback list_issues(Providers.owner(), Providers.repo()) ::
              {:ok, [IssueResponse.t()]} | {:error, Providers.error()}

  @callback list_contributors(Providers.owner(), Providers.repo()) ::
              {:ok, [ContributorResponse.t()]} | {:error, Providers.error()}

  @callback get_user(Providers.login()) ::
              {:ok, [UserResponse.t()]} | {:error, Providers.error()}
end
