defmodule Bank.AuthTest do
  use Bank.DataCase, async: true

  alias Bank.{Auth, Users, Users.User}

  describe "authenticate_user/2" do
    test "returns success when user credentials are correct" do
      credentials = %{email: "john.doe@test.com", password: "123456"}
      Users.create(credentials)

      assert {:ok, %User{email: "john.doe@test.com"}} = Auth.authenticate_user(credentials)
    end

    test "returns error when user can not be found" do
      credentials = %{email: "john.doe@test.com", password: "123456"}

      assert Auth.authenticate_user(credentials) == :error
    end

    test "returns error when password verification fails" do
      credentials = %{email: "john.doe@test.com", password: "123456"}
      Users.create(credentials)

      wrong_credentials = Map.put(credentials, :password, "wrong_pass")

      assert Auth.authenticate_user(wrong_credentials) == :error
    end
  end

  @user_id "138b6176-3f28-4882-a7f8-e2d7518c68ea"

  describe "generate_auth_token/1" do
    test "generates an auth token for a user id" do
      token = Auth.generate_auth_token(@user_id)

      assert is_binary(token)
      assert String.length(token) == 148
    end
  end

  describe "verify_auth_token/1" do
    test "returns success tuple with the user id when token can be verified" do
      token = Auth.generate_auth_token(@user_id)

      assert Auth.verify_auth_token(token) == {:ok, @user_id}
    end

    test "returns error tuple when token is expired" do
      token = Auth.generate_auth_token(@user_id)
      max_age = 0

      assert Auth.verify_auth_token(token, max_age) == {:error, :expired}
    end

    test "returns error tuple when token is invalid" do
      token = "invalid-token"

      assert Auth.verify_auth_token(token) == {:error, :invalid}
    end
  end
end
