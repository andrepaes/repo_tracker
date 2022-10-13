defmodule RepoTracker.Providers.Impl do
  @moduledoc """
  This module define the contract that every provider should implement
  """

  alias RepoTracker.Providers
  alias RepoTracker.Providers.IssueResponse

  @callback list_issues(Providers.owner(), Providers.repo()) ::
              {:ok, [IssueResponse.t()]} | {:error, Providers.error()}
end
