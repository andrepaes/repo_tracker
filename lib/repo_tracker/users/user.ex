defmodule RepoTracker.Users.User do
  @moduledoc """
  This module represents a Provider user.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:login, :full_name]

  schema "users" do
    field :login, :string
    field :full_name, :string
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
