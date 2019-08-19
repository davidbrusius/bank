defmodule Bank.Repo.Migrations.CreateAccountTransactions do
  use Ecto.Migration

  def change do
    create table(:account_transactions) do
      add :account_id, references(:accounts), null: false

      add :amount, :integer, null: false
      timestamps()
    end
  end
end
