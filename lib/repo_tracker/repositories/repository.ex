defmodule RepoTracker.Repositories.Repository do
  @moduledoc """
  This module represents a Repository.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias RepoTracker.Users.User

  @fields [:repo_name, :owner, :issues, :contributors]
  @required_fields [:repo_name, :owner_id]

  schema "repositories" do
    field :repo_name, :string
    belongs_to :owner_id, User

    embeds_many :issues, Issues, on_replace: :delete do
      field :title, :string
      field :author, :string
      field :labels, {:array, :string}
    end

    many_to_many :contributors, User,
      join_keys: [repository_id: :id, contributor_id: :id],
      join_through: "repository_contributors"
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:contributors)
  end
end
