defmodule Bank.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :user_id, references(:users, on_delete: :nothing), null: false

      add :balance, :integer, null: false, default: 0
      add :number, :string, null: false
      timestamps()
    end

    create unique_index(:accounts, :number)
  end
end
