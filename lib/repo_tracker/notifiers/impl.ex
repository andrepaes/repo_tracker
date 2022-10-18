defmodule RepoTracker.Notifiers.Impl do
  @moduledoc """
  This module define the contract that every channel should implmement to be able to notify clients
  """

  alias RepoTracker.Notifiers

  @callback notify(Notifiers.data(), Notifiers.target()) :: {:ok, any()} | {:error, any()}
end
