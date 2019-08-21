defmodule Bank.Accounts.TransferValidatorTest do
  use ExUnit.Case, async: true

  alias Bank.Accounts.{Account, TransferValidator}
  alias Bank.Users.User

  @user_id "138b6176-3f28-4882-a7f8-e2d7518c68ea"

  describe "validate/1" do
    test "returns success tuple when all requirements are met" do
      operation = %{
        user: %User{id: @user_id},
        source_account: %Account{number: "1234", balance: Money.new(50), user_id: @user_id},
        dest_account: %Account{number: "1235", balance: Money.new(10)},
        amount: 30
      }

      {:ok, changeset} = TransferValidator.validate(operation)

      assert changeset.valid?
    end

    test "returns an error tuple when attributes are missing" do
      operation = %{}

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors ==
               [
                 amount: {"can't be blank", [validation: :required]},
                 dest_account: {"can't be blank", [validation: :required]},
                 source_account: {"can't be blank", [validation: :required]},
                 user: {"can't be blank", [validation: :required]}
               ]
    end

    test "returns an error tuple when source account does not have enough funds to transfer" do
      operation = %{
        user: %User{id: @user_id},
        source_account: %Account{number: "1234", balance: Money.new(50), user_id: @user_id},
        dest_account: %Account{number: "1235", balance: Money.new(10)},
        amount: 100
      }

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors == [source_account: {"does not have enough funds to transfer", []}]
    end

    test "returns an error tuple when source account does not belong to user" do
      operation = %{
        user: %User{id: @user_id},
        source_account: %Account{number: "1234", balance: Money.new(50), user_id: "another-id"},
        dest_account: %Account{number: "1235", balance: Money.new(10)},
        amount: 30
      }

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors == [source_account: {"does not belong to user", []}]
    end

    test "returns an error tuple when source account is the same as dest account" do
      account = %Account{number: "1234", balance: Money.new(50), user_id: @user_id}

      operation = %{
        user: %User{id: @user_id},
        source_account: account,
        dest_account: account,
        amount: 30
      }

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors == [dest_account: {"can not transfer to the same account", []}]
    end

    test "returns an error tuple when amount is zero" do
      operation = %{
        user: %User{id: @user_id},
        source_account: %Account{number: "1234", balance: Money.new(50), user_id: @user_id},
        dest_account: %Account{number: "1235", balance: Money.new(10)},
        amount: 0
      }

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors == [amount: {"should be greater than 0", []}]
    end

    test "returns an error tuple when amount is negative" do
      operation = %{
        user: %User{id: @user_id},
        source_account: %Account{number: "1234", balance: Money.new(50), user_id: @user_id},
        dest_account: %Account{number: "1235", balance: Money.new(10)},
        amount: -30
      }

      {:error, changeset} = TransferValidator.validate(operation)

      assert changeset.errors == [amount: {"should be greater than 0", []}]
    end
  end
end
