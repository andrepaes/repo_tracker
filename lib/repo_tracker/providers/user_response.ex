defmodule RepoTracker.Providers.UserResponse do
  @type t :: %{
          name: String.t()
        }

  defstruct [:name]
end
