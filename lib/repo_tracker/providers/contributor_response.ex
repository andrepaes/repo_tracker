defmodule RepoTracker.Providers.ContributorResponse do
  @type t :: %{
          login: String.t(),
          commits_quantity: non_neg_integer()
        }

  defstruct [:login, :commits_quantity]
end
