defmodule RepoTracker.Repositories.Repository do
  @moduledoc """
  This module represents a Repository.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias RepoTracker.Users.User

  @fields [:repo_name, :owner_id]
  @required_fields [:repo_name, :owner_id]
  @issue_fields [:title, :login, :labels]
  @foreign_key_type :binary_id

  schema "repositories" do
    field :repo_name, :string
    belongs_to :owner, User

    embeds_many :issues, Issues, on_replace: :delete do
      field :title, :string
      field :login, :string
      field :labels, {:array, :string}
    end

    many_to_many :contributors, User,
      join_keys: [repository_id: :id, contributor_id: :id],
      join_through: RepoTracker.Contribution
  end

  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @fields)
    |> cast_embed(:issues, with: &cast(&1, &2, @issue_fields))
    |> validate_required(@required_fields)
  end
end
