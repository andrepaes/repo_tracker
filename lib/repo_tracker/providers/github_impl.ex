defmodule RepoTracker.Providers.GithubImpl do
  @moduledoc """
  Github implementation
  """

  @behaviour RepoTracker.Providers.Impl

  require Logger
  alias RepoTracker.Providers.IssueResponse

  @impl true
  def list_issues(owner, repo) do
    case Tentacat.Issues.list(owner, repo) do
      {200, issues, _resp_headers} ->
        {:ok, apply_issue_response(issues)}

      {code, %{"message" => message}, _resp_headers} ->
        Logger.error(
          "Can't get issues from repository: #{owner}/#{repo} because of: #{inspect(message)}"
        )

        {:error, %{code: code, message: message}}
    end
  end

  defp apply_issue_response(%{"title" => title, "author" => author, "labels" => labels}) do
    %IssueResponse{title: title, author: author, labels: labels}
  end
end
