defmodule RepoTracker.Repositories.Contribution do
  @moduledoc """
  This module represents a contribution on a repository
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias RepoTracker.Repositories.Repository
  alias RepoTracker.Users.User

  @fields [:commits_quantity, :repository_id, :contributor_id]

  schema "contributions" do
    field :commits_quantity, :integer
    belongs_to :repository, Repository, type: :id
    belongs_to :contributor, User, type: :binary_id
  end

  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
