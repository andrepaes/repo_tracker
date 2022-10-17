defmodule RepoTracker.Repo.Migrations.CreateRepositoriesContributorsTable do
  use Ecto.Migration

  def change do
    create table(:contributions) do
      add :commits_quantity, :integer, null: false
      add :repository_id, references(:repositories, type: :id)
      add :contributor_id, references(:users, type: :binary_id)
    end

    create unique_index(:contributions, [:repository_id, :contributor_id])
  end
end
