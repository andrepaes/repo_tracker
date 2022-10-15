defmodule RepoTracker.Users.User do
  @moduledoc """
  This module represents a Provider user.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:login, :full_name]

  schema "users" do
    field :login, :string, null: false
    field :full_name, :string, null: false
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(parms, @fields)
    |> validate_required(@fields)
  end
end
