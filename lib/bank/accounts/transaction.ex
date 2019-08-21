defmodule Bank.Accounts.Transaction do
  @moduledoc false

  use Bank.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: binary(),
          account: Bank.Accounts.Account.t() | %Ecto.Association.NotLoaded{},
          amount: Money.Ecto.Amount.Type.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "account_transactions" do
    belongs_to :account, Bank.Accounts.Account

    field :amount, Money.Ecto.Amount.Type
    timestamps()
  end

  def changeset(transaction, account, attrs) do
    transaction
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> put_assoc(:account, account)
    |> validate_required([:account])
  end
end
