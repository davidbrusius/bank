defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase, async: true

  alias Bank.{AccountsHelper, UsersHelper}

  describe "GET - /accounts/:number" do
    setup do
      user = UsersHelper.create_user()
      {:ok, user: user, conn: authenticated_conn(user.id)}
    end

    test "returns account informations", %{user: user, conn: conn} do
      account = AccountsHelper.create_account(user, 100, %{number: "1234"})

      response =
        conn
        |> get(Routes.account_path(conn, :show, account.number))
        |> json_response(200)

      assert response == %{
               "account" => %{
                 "number" => "1234",
                 "balance" => "R$ 100.00"
               }
             }
    end

    test "returns not found when account does not belong to the authenticated user", %{conn: conn} do
      other_user = UsersHelper.create_user(%{email: "jane.doe@test.com"})
      account = AccountsHelper.create_account(other_user, 50_000, %{number: "1234"})

      response =
        conn
        |> get(Routes.account_path(conn, :show, account.number))
        |> json_response(404)

      assert response == %{"error" => %{"message" => "Unable to find account with number 1234."}}
    end

    test "returns not found when account does not exist", %{conn: conn} do
      response =
        conn
        |> get(Routes.account_path(conn, :show, "1234"))
        |> json_response(404)

      assert response == %{"error" => %{"message" => "Unable to find account with number 1234."}}
    end
  end
end
