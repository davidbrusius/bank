defmodule Bank.Accounts do
  @moduledoc """
  Functions for dealing with Account resources such as Bank.Accounts.Account and
  Bank.Accounts.Transaction.
  """

  import Ecto.Query

  alias Bank.Repo

  alias Bank.Accounts.{Account, DepositOperation, TransferOperation, WithdrawOperation}
  alias Bank.DecimalAdapter
  alias Bank.Users.User
  alias Ecto.Multi

  @type transfer_error :: {:error, :validate_transfer, Ecto.Changeset.t(), map()}
  @type account_not_found_error :: {:error, :account_not_found, map()}

  @doc """
  Creates a new account with the given attributes.
  """
  @spec create(User.t(), map()) :: {:ok, Account.t()} | {:error, %Ecto.Changeset{}}
  def create(user, attrs) do
    %Account{}
    |> Account.changeset(user, attrs)
    |> Repo.insert()
  end

  @doc """
  Fetches a user account from the database, filtering by the given field.
  """
  @spec get_by(User.t(), atom(), any()) :: {:ok, Account.t()} | {:error, atom()}
  def get_by(user, field, value) do
    query = from a in Account, where: a.user_id == ^user.id and field(a, ^field) == ^value

    case Repo.one(query) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @doc """
  Performs a deposit operation on the provided account. This operation will add a new Transaction to
  the account and then recalculate the account balance adding the amount to it. Deposit operations are
  performed with a lock in the account record to prevent issues while calculating the final account balance.
  """
  @spec deposit(String.t(), number()) :: {:ok, map()} | account_not_found_error()
  def deposit(account_number, amount) do
    Multi.new()
    |> Multi.run(:account, fn _, _ -> get_account_for_operation(account_number) end)
    |> Multi.merge(fn %{account: account} ->
      DepositOperation.prepare(%{account: account, amount: DecimalAdapter.to_storage(amount)})
    end)
    |> Repo.transaction()
  end

  @doc """
  Performs a withdraw operation on the provided account. This operation will add a new Transaction
  to the account and then recalculate the account balance subtracting the amount from it. Withdraw
  operations are performed with a lock in the account record to prevent issues while calculating
  the final account balance.
  """
  @spec withdraw(String.t(), number()) :: {:ok, map()} | account_not_found_error()
  def withdraw(account_number, amount) do
    Multi.new()
    |> Multi.run(:account, fn _, _ -> get_account_for_operation(account_number) end)
    |> Multi.merge(fn %{account: account} ->
      WithdrawOperation.prepare(%{account: account, amount: DecimalAdapter.to_storage(amount)})
    end)
    |> Repo.transaction()
  end

  @doc """
  Performs a transfer operation on the provided accounts. This operation will perform a withdraw
  operation on the source account and then perform a deposit operation on the destination account,
  these operations are done in the same database transaction to avoid inconsistent results in case
  of a failure in one of the operations. Transfer operations are also performed with a lock on both
  accounts records at the same time to prevent issues while calculating the final accounts balances.

  To ensure all requirements for a transfer are met, some validations are performed. Check
  Bank.Accounts.TransferValidator module for more details.
  """
  @spec transfer(User.t(), String.t(), String.t(), number()) :: {:ok, map()} | transfer_error()
  def transfer(user, source_account_number, dest_account_number, amount) do
    Multi.new()
    |> Multi.run(:accounts, fn _, _ ->
      get_accounts_for_transfer(source_account_number, dest_account_number)
    end)
    |> Multi.merge(fn %{accounts: accounts} ->
      accounts
      |> Map.merge(%{user: user, amount: DecimalAdapter.to_storage(amount)})
      |> TransferOperation.prepare()
    end)
    |> Repo.transaction()
  end

  defp get_accounts_for_transfer(source_account_number, dest_account_number) do
    query =
      from a in Account,
        where: a.number in [^source_account_number, ^dest_account_number],
        lock: "FOR UPDATE"

    accounts = Repo.all(query)

    {
      :ok,
      %{
        source_account: Enum.find(accounts, &(&1.number == source_account_number)),
        dest_account: Enum.find(accounts, &(&1.number == dest_account_number))
      }
    }
  end

  defp get_account_for_operation(account_number) do
    query = from a in Account, where: a.number == ^account_number, lock: "FOR UPDATE"

    case Repo.one(query) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
