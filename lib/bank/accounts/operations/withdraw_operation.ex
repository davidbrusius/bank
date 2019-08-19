defmodule Bank.Accounts.WithdrawOperation do
  @moduledoc false

  @behaviour Bank.Account.Operation

  alias Bank.Accounts.{Account, Transaction}
  alias Ecto.Multi

  @spec prepare(map()) :: Ecto.Multi.t()
  def prepare(%{account: account, amount: amount}) do
    transaction = Transaction.changeset(%Transaction{}, account, %{amount: -amount})
    balance = Account.changeset(account, %{balance: account.balance.amount - amount})

    Multi.new()
    |> Multi.insert(:account_withdraw, transaction)
    |> Multi.update(:account_withdraw_balance, balance)
  end
end
