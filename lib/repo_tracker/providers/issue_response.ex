defmodule RepoTracker.Providers.IssueResponse do
  @type t :: %{
          title: String.t(),
          login: String.t(),
          labels: [String.t()]
        }

  defstruct [:title, :login, :labels]
end
