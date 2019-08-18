defmodule Bank.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:users) do
      add :email, :citext, null: false
      add :password_hash, :string, null: false
      timestamps()
    end

    create unique_index(:users, :email)
  end

  def down do
    drop index(:users, :email)
    drop table(:users)

    execute "DROP EXTENSION IF EXISTS citext"
  end
end
