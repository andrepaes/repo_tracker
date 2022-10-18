Mox.defmock(GithubProvidersMock, for: RepoTracker.Providers.Impl)
Mox.defmock(WebhookNotifiersMock, for: RepoTracker.Notifiers.Impl)
Application.put_env(:repo_tracker, :providers, %{github: GithubProvidersMock})
Application.put_env(:repo_tracker, :notifiers, %{webhook: WebhookNotifiersMock})

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(RepoTracker.Repo, :manual)
