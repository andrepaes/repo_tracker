defmodule RepoTracker.Providers.ContributorResponse do
  @type t :: %{
          name: String.t(),
          login: String.t(),
          commits_quantity: non_neg_integer()
        }

  defstruct [:login, :commits_quantity, :name]
end
