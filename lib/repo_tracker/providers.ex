defmodule RepoTracker.Providers do
  @moduledoc """
  This module defines an api to interact with any repository on any integrated provider
  """

  @type repo :: String.t()
  @type owner :: String.t()
  @type providers :: [:github]

  @spec list_issues(providers(), owner(), repo()) :: [Providers.Issue.t()]
  def list_issues(provider, owner, repo) do
    impl(provider).list(owner, repo)
  end

  defp impl(:github) do

  end
end
