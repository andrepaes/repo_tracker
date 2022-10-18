defmodule RepoTracker.Notifiers do
  @defmodule """
  This module defines an api to send notifications
  """

  @type channel :: :webhook
  @type data :: any()
  @type target :: String.t()

  alias RepoTracker.Notifiers.WebhookImpl

  @spec notify(channel(), data(), target()) :: {:ok, any()} | {:error, any()}
  def notify(channel, data, target) do
    impl(channel).notify(data, target)
  end

  defp impl(channel) do
    Application.get_env(:repo_tracker, :notifiers, %{webhook: WebhookImpl})[channel]
  end
end
