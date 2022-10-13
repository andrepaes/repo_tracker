defmodule RepoTracker.Providers.Impl do
  @moduledoc """
  This module define the contract that every provider should implement
  """

  alias RepoTracker.Providers

  @callback list_issues(Providers.owner(), Providers.repo()) :: [Tentacat.response()]
end
