defmodule BankWeb.Plugs.AuthTest do
  use BankWeb.ConnCase, async: true

  import Plug.Conn, only: [put_req_header: 3]

  alias BankWeb.Plugs.Auth, as: AuthPlug
  alias Bank.{Auth, Users}

  test "pass through and set current user assign when Bearer token is valid" do
    {:ok, user} = Users.create(%{email: "jane.doe@test.com", password: "123456"})
    token = Auth.generate_auth_token(user.id)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> AuthPlug.call(%{})

    assert conn.assigns.current_user.id == user.id
    assert conn.assigns.current_user.email == user.email
  end

  test "halts the connection and return unauthorized response when Bearer token is invalid" do
    token = "invalid-token"

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> AuthPlug.call(%{})

    assert conn.status == 401
    assert conn.halted
  end

  test "halts the connection and return unauthorized response when the user can not be found" do
    user_id = "138b6176-3f28-4882-a7f8-e2d7518c68ea"
    token = Auth.generate_auth_token(user_id)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> AuthPlug.call(%{})

    assert conn.status == 401
    assert conn.halted
  end

  test "halts the connection and return unauthorized response when token is not provided" do
    conn = AuthPlug.call(build_conn(), %{})

    assert conn.status == 401
    assert conn.halted
  end
end
