defmodule RepoTracker.Notifiers.WebhookImpl do
  @defmodule """
  Module that implement the notifiers contract to webhooks
  """

  @behaviour RepoTracker.Notifiers.Impl

  @impl true
  def notify(data, target) do
    HTTPoison.post(target, data)
  end
end
