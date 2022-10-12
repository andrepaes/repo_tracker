defmodule RepoTracker.Repo do
  use Ecto.Repo,
    otp_app: :repo_tracker,
    adapter: Ecto.Adapters.Postgres
end
