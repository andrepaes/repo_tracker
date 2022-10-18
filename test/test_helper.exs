Mox.defmock(GithubProvidersMock, for: RepoTracker.Providers.Impl)
Application.put_env(:repo_tracker, :providers, %{github: GithubProvidersMock})

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(RepoTracker.Repo, :manual)
