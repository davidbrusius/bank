defmodule BankWeb.Account.TransferView do
  use BankWeb, :view

  def render("created.json", %{accounts: accounts, amount: amount}) do
    %{
      message: "Successfully transferred amount to destination account.",
      source_account_number: accounts.source_account.number,
      dest_account_number: accounts.dest_account.number,
      amount: Money.to_string(amount)
    }
  end

  def render("error.json", %{changeset: changeset}) do
    %{error: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end
end
