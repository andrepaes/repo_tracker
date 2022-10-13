defmodule RepoTracker.Providers.IssueResponse do
  @type t :: %{
          title: String.t(),
          author: String.t(),
          labels: [String.t()]
        }

  defstruct [:title, :author, :labels]
end
