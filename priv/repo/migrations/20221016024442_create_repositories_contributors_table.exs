defmodule RepoTracker.Repo.Migrations.CreateRepositoriesContributorsTable do
  use Ecto.Migration

  def change do
    create table(:repositories_contributors) do
      add :repository_id, references(:repositories, type: :id)
      add :contributor_id, references(:users, type: :binary_id)
    end

    create unique_index(:repositories_contributors, [:repository_id, :contributor_id])
  end
end
