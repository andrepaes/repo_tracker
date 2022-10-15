defmodule RepoTracker.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :login, :string, null: false
      add :full_name, :string, null: false
    end

    create index(:users, :login)
  end
end
