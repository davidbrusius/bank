defmodule BankWeb.Auth.TokenControllerTest do
  use BankWeb.ConnCase, async: true

  alias Bank.Users

  describe "POST - /auth/token" do
    setup do
      {:ok, conn: build_conn()}
    end

    test "returns a token when user credentials are valid", %{conn: conn} do
      credentials = %{email: "jane.doe@test.com", password: "123456"}
      Users.create(credentials)

      %{"token" => token} =
        conn
        |> post(Routes.token_path(conn, :create), credentials)
        |> json_response(201)

      assert is_binary(token)
    end

    test "returns an error when email can not be found", %{conn: conn} do
      credentials = %{email: "jane.doe@test.com", password: "123456"}

      response =
        conn
        |> post(Routes.token_path(conn, :create), credentials)
        |> json_response(401)

      assert response == %{"error" => "Invalid email or password"}
    end

    test "returns an error when password is incorrect", %{conn: conn} do
      credentials = %{email: "jane.doe@test.com", password: "123456"}
      Users.create(credentials)

      wrong_credentials = Map.put(credentials, :password, "wrong_pass")

      response =
        conn
        |> post(Routes.token_path(conn, :create), wrong_credentials)
        |> json_response(401)

      assert response == %{"error" => "Invalid email or password"}
    end
  end
end
