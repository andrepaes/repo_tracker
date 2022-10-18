defmodule RepoTracker.Providers.UserResponse do
  @moduledoc false
  @type t :: %{
          name: String.t()
        }

  defstruct [:name]
end
