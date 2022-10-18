defmodule RepoTracker.Notifiers do
  @moduledoc """
  This module defines an api to send notifications
  """

  @type channel :: :webhook
  @type data :: any()
  @type target :: String.t()

  alias RepoTracker.Notifiers.WebhookImpl

  @spec notify(channel(), target(), data()) :: {:ok, any()} | {:error, any()}
  def notify(channel, target, data) do
    impl(channel).notify(target, data)
  end

  defp impl(channel) do
    Application.get_env(:repo_tracker, :notifiers, %{webhook: WebhookImpl})[channel]
  end
end
