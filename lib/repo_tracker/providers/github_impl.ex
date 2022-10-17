defmodule RepoTracker.Providers.GithubImpl do
  @moduledoc """
  Github implementation
  """

  @behaviour RepoTracker.Providers.Impl

  require Logger

  alias Tentacat.Issues
  alias Tentacat.Repositories.Contributors
  alias Tentacat.Users

  alias RepoTracker.Providers.ContributorResponse
  alias RepoTracker.Providers.IssueResponse
  alias RepoTracker.Providers.UserResponse

  @impl true
  def list_issues(owner, repo) do
    case Issues.list(client(), owner, repo) do
      {200, issues, _resp_headers} ->
        {:ok, Enum.map(issues, &apply_issue_response/1)}

      {code, %{"message" => message}, _resp_headers} ->
        Logger.error(
          "Can't get issues from repository: #{owner}/#{repo} because of: #{inspect(message)}"
        )

        {:error, %{code: code, message: message}}
    end
  end

  @impl true
  def list_contributors(owner, repo) do
    case Contributors.list(client(), owner, repo) do
      {200, contributors, _resp_headers} ->
        {:ok, Enum.map(contributors, &apply_contributor_response/1)}

      {code, %{"message" => message}, _resp_headers} ->
        Logger.error(
          "Can't get contributors from repository: #{owner}/#{repo} because of: #{inspect(message)}"
        )

        {:error, %{code: code, message: message}}
    end
  end

  @impl true
  def get_user(login) do
    case Users.find(login) do
      {200, user, _resp_headers} ->
        {:ok, apply_user_response(user)}

      {code, %{"message" => message}, _resp_headers} ->
        Logger.error("Can't get user: #{login}")

        {:error, %{code: code, message: message}}
    end
  end

  defp apply_issue_response(%{
         "title" => title,
         "user" => user,
         "labels" => labels
       }) do
    labels = Enum.map(labels, fn %{"name" => name} -> name end)
    login = Map.get(user, "login", nil)
    %IssueResponse{title: title, login: login, labels: labels}
  end

  defp apply_contributor_response(%{"contributions" => contribuitions, "login" => login}) do
    %ContributorResponse{login: login, commits_quantity: contribuitions}
  end

  defp apply_user_response(%{"name" => name}) do
    %UserResponse{name: name}
  end

  defp client() do
    Tentacat.Client.new(%{access_token: "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"})
  end
end
