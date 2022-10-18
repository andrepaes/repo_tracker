defmodule RepoTracker.Workers.UsersFetcher do
  use Oban.Worker

  alias RepoTracker.Providers
  alias RepoTracker.Repo
  alias RepoTracker.Users.User

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"login" => login, "provider" => provider}}) do
    provider = String.to_existing_atom(provider)

    with {:ok, %{name: name}} <- Providers.fetch_user(provider, login) do
      case Repo.get_by(User, login: login) do
        %{full_name: nil} = user ->
          user
          |> User.changeset(%{full_name: name})
          |> Repo.update()

        _already_filled_user ->
          :ok
      end
    end
  end
end
