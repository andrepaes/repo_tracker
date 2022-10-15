defmodule RepoTracker.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      field(:login, :string, null: false)
      field(:full_name, :string, null: false)
    end
  end
end
