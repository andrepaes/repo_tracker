Mox.defmock(GithubProvidersMock, for: RepoTracker.Providers.Impl)
Application.put_env(:repo_tracker, :providers, %{github: GithubProvidersMock})

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(RepoTracker.Repo, :manual)
