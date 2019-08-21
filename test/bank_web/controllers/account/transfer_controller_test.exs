defmodule BankWeb.Account.TransferControllerTest do
  use BankWeb.ConnCase, async: true

  alias Bank.{AccountsHelper, UsersHelper}

  describe "POST - /accounts/transfer" do
    setup do
      user = UsersHelper.create_user()
      {:ok, user: user, conn: authenticated_conn(user.id)}
    end

    test "transfers the amount from source account to dest account", %{user: user, conn: conn} do
      source_account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})

      params = %{
        source_account_number: source_account.number,
        dest_account_number: dest_account.number,
        amount: 25.50
      }

      response =
        conn
        |> post(Routes.transfer_path(conn, :create), params)
        |> json_response(201)

      assert response == %{
               "message" => "Successfully transferred amount to destination account.",
               "source_account_number" => source_account.number,
               "dest_account_number" => dest_account.number,
               "amount" => "R$ 25.50"
             }
    end

    test "renders validation errors when transfer validations fail", %{user: user, conn: conn} do
      source_account = AccountsHelper.create_account(user, 100, %{number: "1234"})
      dest_account = AccountsHelper.create_account(user, 0, %{number: "1235"})

      params = %{
        source_account_number: source_account.number,
        dest_account_number: dest_account.number,
        amount: 150
      }

      response =
        conn
        |> post(Routes.transfer_path(conn, :create), params)
        |> json_response(422)

      assert response == %{
               "error" => %{"source_account" => ["does not have enough funds to transfer"]}
             }
    end

    test "returns unauthorized when user is not authenticated" do
      conn = build_conn()

      response =
        conn
        |> post(Routes.transfer_path(conn, :create), %{})
        |> response(401)

      assert response == "Unauthorized"
    end
  end
end
