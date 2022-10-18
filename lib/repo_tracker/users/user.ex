defmodule RepoTracker.Users.User do
  @moduledoc """
  This module represents a Provider user.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:login, :full_name]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :login, :string
    field :full_name, :string, default: nil
  end

  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @fields)
    |> validate_required([:login])
  end
end
