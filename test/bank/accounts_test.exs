defmodule Bank.AccountsTest do
  use Bank.DataCase, async: true

  alias Bank.Accounts
  alias Bank.Accounts.Account
  alias Bank.{AccountsHelper, UsersHelper}
  alias Bank.Repo

  describe "create/1" do
    test "creates an account and associates the user when attributes are valid" do
      user = UsersHelper.create_user()
      attrs = %{number: "1234"}

      {:ok, account} = Accounts.create(user, attrs)

      assert account.balance == %Money{amount: 0, currency: :BRL}
      assert account.number == "1234"
      assert account.user == user
    end

    test "returns an error changeset when number is missing" do
      user = UsersHelper.create_user()
      attrs = %{}

      {:error, %Ecto.Changeset{} = changeset} = Accounts.create(user, attrs)

      assert changeset.errors == [number: {"can't be blank", [validation: :required]}]
    end

    test "returns an error changeset when number is already taken" do
      user = UsersHelper.create_user()
      attrs = %{number: "1234"}

      {:ok, _account} = Accounts.create(user, attrs)
      {:error, %Ecto.Changeset{} = changeset} = Accounts.create(user, attrs)

      assert changeset.errors == [
               number:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "accounts_number_index"]}
             ]
    end

    test "returns an error changeset when user association is missing" do
      attrs = %{number: "1234"}

      {:error, %Ecto.Changeset{} = changeset} = Accounts.create(nil, attrs)

      assert changeset.errors == [user: {"can't be blank", [validation: :required]}]
    end
  end

  describe "deposit/2" do
    test "performs a deposit operation for the given account number" do
      account = AccountsHelper.create_account()
      amount = 100

      {:ok, _} = Accounts.deposit(account.number, amount)

      account = Account |> Repo.get(account.id) |> Repo.preload(:transactions)
      transaction = List.last(account.transactions)

      assert transaction.amount == %Money{amount: 10_000, currency: :BRL}
      assert account.balance == %Money{amount: 10_000, currency: :BRL}
    end

    test "returns an error tuple when account does not exist" do
      assert Accounts.deposit("1234", 100) == {:error, :account, :account_not_found, %{}}
    end
  end

  describe "withdraw/2" do
    test "performs a withdraw operation for the given account number" do
      account = AccountsHelper.create_account(500)
      amount = 300

      {:ok, _} = Accounts.withdraw(account.number, amount)

      account = Account |> Repo.get(account.id) |> Repo.preload(:transactions)
      transaction = List.last(account.transactions)

      assert transaction.amount == %Money{amount: -30_000, currency: :BRL}
      assert account.balance == %Money{amount: 20_000, currency: :BRL}
    end

    test "returns an error tuple when account does not exist" do
      assert Accounts.deposit("1234", 100) == {:error, :account, :account_not_found, %{}}
    end
  end

  describe "transfer/4" do
    test "performs transfer operation from source account to dest account" do
      user = UsersHelper.create_user()
      source_account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})
      amount = 100

      {:ok, _} = Accounts.transfer(user, source_account.number, dest_account.number, amount)

      source_account = Account |> Repo.get(source_account.id) |> Repo.preload(:transactions)
      withdraw_transaction = List.last(source_account.transactions)

      dest_account = Account |> Repo.get(dest_account.id) |> Repo.preload(:transactions)
      deposit_transaction = List.last(dest_account.transactions)

      assert source_account.balance == %Money{amount: 0, currency: :BRL}
      assert withdraw_transaction.amount == %Money{amount: -10_000, currency: :BRL}

      assert dest_account.balance == %Money{amount: 10_000, currency: :BRL}
      assert deposit_transaction.amount == %Money{amount: 10_000, currency: :BRL}
    end

    test "does not perform transfer operation when source account does not have enough funds to transfer" do
      user = UsersHelper.create_user()
      source_account = AccountsHelper.create_account(user, 0, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})
      amount = 100

      {:error, :validate_transfer, changeset, _} =
        Accounts.transfer(user, source_account.number, dest_account.number, amount)

      assert changeset.errors == [source_account: {"does not have enough funds to transfer", []}]
    end

    test "does not perform transfer operation when source account does not belong to user" do
      user = UsersHelper.create_user(%{email: "john.doe@test.com"})
      another_user = UsersHelper.create_user(%{email: "jane.doe@test.com"})
      source_account = AccountsHelper.create_account(another_user, 0, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})
      amount = 100

      {:error, :validate_transfer, changeset, _} =
        Accounts.transfer(user, source_account.number, dest_account.number, amount)

      assert changeset.errors == [source_account: {"does not belong to user", []}]
    end

    test "does not perform transfer operation when both accounts are the same" do
      user = UsersHelper.create_user()
      account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      amount = 100

      {:error, :validate_transfer, changeset, _} =
        Accounts.transfer(user, account.number, account.number, amount)

      assert changeset.errors == [dest_account: {"can not transfer to the same account", []}]
    end

    test "does not perform transfer operation when amount is negative" do
      user = UsersHelper.create_user()
      source_account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})
      amount = -100

      {:error, :validate_transfer, changeset, _} =
        Accounts.transfer(user, source_account.number, dest_account.number, amount)

      assert changeset.errors == [amount: {"should be greater than 0", []}]
    end

    test "does not perform transfer operation when amount is zero" do
      user = UsersHelper.create_user()
      source_account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})
      amount = 0

      {:error, :validate_transfer, changeset, _} =
        Accounts.transfer(user, source_account.number, dest_account.number, amount)

      assert changeset.errors == [amount: {"should be greater than 0", []}]
    end
  end
end
