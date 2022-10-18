defmodule RepoTracker.Workers.UsersFetcher do
  use Oban.Worker

  alias RepoTracker.Providers
  alias RepoTracker.Repo
  alias RepoTracker.Users.User

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"login" => login, "provider" => provider}}) do
    provider = String.to_existing_atom(provider)

    with {:ok, %{name: name}} <- Providers.fetch_user(provider, login) do
      case Repo.get_by(User, login: login) do
        %{full_name: nil} = user -> Repo.update(user, User.changeset(user, %{full_name: name}))
        _already_filled_user -> :ok
      end
    end
  end
end
