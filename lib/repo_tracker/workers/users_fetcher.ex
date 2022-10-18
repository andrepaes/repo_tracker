defmodule RepoTracker.Workers.UsersFetcher do
  use Oban.Worker

  alias RepoTracker.Providers
  alias RepoTracker.Repo
  alias RepoTracker.Users.User

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"login" => login, "provider" => provider}}) do
    provider = String.to_existing_atom(provider)

    case Repo.get_by(User, login: login) do
      %{full_name: nil} = user ->
        fill_user_name(user, provider, login)

      _already_filled_user ->
        :ok
    end
  end

  defp fill_user_name(%User{} = user, provider, login) do
    case Providers.fetch_user(provider, login) do
      {:ok, %{name: name}} ->
        user
        |> User.changeset(%{full_name: name})
        |> Repo.update()

        :ok

      {:error, _} = error ->
        error
    end
  end
end
