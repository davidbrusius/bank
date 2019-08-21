defmodule BankWeb.Account.TransferController do
  use BankWeb, :controller

  alias Bank.Accounts

  def create(%{assigns: %{current_user: user}} = conn, params) do
    case Accounts.transfer(
           user,
           params["source_account_number"],
           params["dest_account_number"],
           params["amount"]
         ) do
      {:ok, %{accounts: accounts, account_deposit: account_deposit}} ->
        conn
        |> put_status(:created)
        |> render("created.json", accounts: accounts, amount: account_deposit.amount)

      {:error, :validate_transfer, changeset, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end
end
