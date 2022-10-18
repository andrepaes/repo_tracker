defmodule RepoTracker.Providers.ContributorResponse do
  @type t :: %{
          login: String.t(),
          commits_quantity: non_neg_integer(),
          full_name: String.t()
        }

  defstruct [:login, :commits_quantity, full_name: nil]
end
