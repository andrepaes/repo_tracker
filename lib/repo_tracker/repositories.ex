defmodule RepoTracker.Repositories do
  @moduledoc """
  Module reponsible to provide an api to work with repositories including cross-context functionalities
  """

  alias RepoTracker.Providers

  @spec fetch_issues(Providers.provider(), Providers.repo(), Providers.login()) ::
          {:ok, [{title :: String.t(), author :: String.t(), labels :: [String.t()]}]}
          | Providers.error()
  def fetch_issues(provider, repo_name, login) do
    with {:ok, issues} <- Providers.list_issues(provider, login, repo_name) do
      formatted_issue =
        Enum.map(issues, fn
          %{title: title, login: author, labels: labels} ->
            {title, author, labels}
        end)

      {:ok, formatted_issue}
    end
  end
end
