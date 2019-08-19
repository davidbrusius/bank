defmodule Bank.Accounts.DepositOperation do
  @moduledoc false

  @behaviour Bank.Account.Operation

  alias Bank.Accounts.{Account, Transaction}
  alias Ecto.Multi

  @spec prepare(map()) :: Ecto.Multi.t()
  def prepare(%{account: account, amount: amount}) do
    transaction = Transaction.changeset(%Transaction{}, account, %{amount: amount})
    account_balance = Account.changeset(account, %{balance: account.balance.amount + amount})

    Multi.new()
    |> Multi.insert(:account_deposit, transaction)
    |> Multi.update(:account_deposit_balance, account_balance)
  end
end
