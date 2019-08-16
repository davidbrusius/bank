defmodule BankWeb.Auth.TokenController do
  use BankWeb, :controller

  alias Bank.Auth

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, %{id: id}} <- Auth.authenticate_user(%{email: email, password: password}),
         token <- Auth.generate_auth_token(id) do
      conn
      |> put_status(:created)
      |> render("authorized.json", token: token)
    else
      :error ->
        conn
        |> put_status(:unauthorized)
        |> render("unauthorized.json")
    end
  end
end
