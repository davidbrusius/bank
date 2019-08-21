defmodule BankWeb.AccountView do
  use BankWeb, :view

  def render("show.json", %{account: account}) do
    %{
      account: %{
        number: account.number,
        balance: Money.to_string(account.balance)
      }
    }
  end

  def render("not_found.json", %{number: number}) do
    %{
      error: %{
        message: "Unable to find account with number #{number}."
      }
    }
  end
end
