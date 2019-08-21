defmodule Bank.AccountsHelper do
  @moduledoc false

  alias Bank.{Accounts, Accounts.Account}
  alias Bank.UsersHelper

  @account_attrs %{number: "1234"}

  def create_account(initial_balance \\ 0) do
    user = UsersHelper.create_user()
    {:ok, %Account{} = account} = Accounts.create(user, @account_attrs)
    add_initial_balance(account, initial_balance)
    account
  end

  def create_account(user, initial_balance, attrs \\ @account_attrs) do
    {:ok, %Account{} = account} = Accounts.create(user, attrs)
    add_initial_balance(account, initial_balance)

    account
  end

  defp add_initial_balance(account, balance) when balance > 0,
    do: Accounts.deposit(account.number, balance)

  defp add_initial_balance(_, _), do: nil
end
