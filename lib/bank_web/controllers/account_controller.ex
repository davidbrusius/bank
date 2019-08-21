defmodule BankWeb.AccountController do
  use BankWeb, :controller

  alias Bank.Accounts

  def show(%{assigns: %{current_user: user}} = conn, params) do
    case Accounts.get_by(user, :number, params["number"]) do
      {:ok, account} ->
        conn
        |> put_status(:ok)
        |> render("show.json", account: account)

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> render("not_found.json", number: params["number"])
    end
  end
end
