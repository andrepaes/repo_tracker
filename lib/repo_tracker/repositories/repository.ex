defmodule RepoTracker.Repositories.Repository do
  @moduledoc """
  This module represents a Repository.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias RepoTracker.Users.User

  @fields [:repo_name, :owner, :issues, :contributors]
  @required_fields [:repo_name, :owner_id]

  @primary_key false
  schema "repositories" do
    # primary key
    field :repo_name, :string, primary_key: true
    belongs_to :owner_id, User, primary_key: true

    embeds_many :issues, Issues, on_replace: :delete do
      field :title, :string
      field :author, :string
      field :labels, {:array, :string}
    end

    many_to_many :contributors, User, join_through: :repository_contributors
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
