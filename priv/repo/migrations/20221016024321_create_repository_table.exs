defmodule RepoTracker.Repo.Migrations.CreateRepositoryTable do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :repo_name, :string, null: false
      add :owner_id, references(:users, type: :binary_id), null: false
      add :issues, :map
    end

    create unique_index(:repositories, [:repo_name, :owner_id])
  end
end
