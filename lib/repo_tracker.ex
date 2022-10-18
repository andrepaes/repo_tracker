defmodule RepoTracker do
  @moduledoc """
  This is the main api of RepoTracker
  """

  alias RepoTracker.Repositories

  defdelegate track_repository(provider, owner, repo, target), to: Repositories
end
