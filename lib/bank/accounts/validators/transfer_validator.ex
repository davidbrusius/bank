defmodule Bank.Accounts.TransferValidator do
  @moduledoc """
  Module responsible for validating transfer requirements.
  """

  import Ecto.Changeset
  alias Ecto.Changeset

  @types %{
    user: :map,
    source_account: :map,
    dest_account: :map,
    amount: :integer
  }

  @spec validate(map()) :: {:ok, Changeset.t()} | {:error, Changeset.t()}
  def validate(transfer) do
    changeset =
      {transfer, @types}
      |> cast(transfer, Map.keys(@types))
      |> validate_required(Map.keys(@types))
      |> validate_amount()
      |> validate_source_account_owner()
      |> validate_source_account_has_funds()
      |> validate_different_accounts()

    case changeset.valid? do
      false -> {:error, changeset}
      true -> {:ok, changeset}
    end
  end

  @min_required_amount 0

  defp validate_amount(%Ecto.Changeset{valid?: true, data: %{amount: amount}} = changeset) do
    case amount > @min_required_amount do
      false -> add_error(changeset, :amount, "should be greater than 0")
      true -> changeset
    end
  end

  defp validate_amount(changeset), do: changeset

  defp validate_source_account_owner(
         %Ecto.Changeset{valid?: true, data: %{source_account: source_account, user: user}} =
           changeset
       ) do
    case source_account.user_id == user.id do
      false -> add_error(changeset, :source_account, "does not belong to user")
      true -> changeset
    end
  end

  defp validate_source_account_owner(changeset), do: changeset

  defp validate_source_account_has_funds(
         %Ecto.Changeset{valid?: true, data: %{source_account: source_account, amount: amount}} =
           changeset
       ) do
    case source_account.balance.amount >= amount do
      false -> add_error(changeset, :source_account, "does not have enough funds to transfer")
      true -> changeset
    end
  end

  defp validate_source_account_has_funds(changeset), do: changeset

  defp validate_different_accounts(
         %Ecto.Changeset{
           valid?: true,
           data: %{source_account: source_account, dest_account: dest_account}
         } = changeset
       ) do
    case source_account.number == dest_account.number do
      false -> changeset
      true -> add_error(changeset, :dest_account, "can not transfer to the same account")
    end
  end

  defp validate_different_accounts(changeset), do: changeset
end
