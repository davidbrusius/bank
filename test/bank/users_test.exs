defmodule Bank.UsersTest do
  use Bank.DataCase, async: true

  alias Bank.{Users, Users.User}

  describe "create/1" do
    test "creates a user when attributes are valid" do
      attrs = %{email: "john.doe@test.com", password: "123456"}

      {:ok, %User{} = user} = Users.create(attrs)

      assert user.email == "john.doe@test.com"
      assert is_binary(user.password_hash)
    end

    test "returns an error changeset when email is invalid" do
      attrs = %{email: "john.doe", password: "123456"}

      {:error, %Ecto.Changeset{} = changeset} = Users.create(attrs)

      assert changeset.errors == [email: {"has invalid format", [validation: :format]}]
    end

    test "returns an error changeset when email is already taken" do
      attrs = %{email: "john.doe@test.com", password: "123456"}
      {:ok, _user} = Users.create(attrs)

      {:error, changeset} = Users.create(attrs)

      assert changeset.errors ==
               [
                 email:
                   {"has already been taken",
                    [constraint: :unique, constraint_name: "users_email_index"]}
               ]
    end

    test "returns an error changeset when attributes are missing" do
      attrs = %{}

      {:error, %Ecto.Changeset{} = changeset} = Users.create(attrs)

      assert changeset.errors == [
               email: {"can't be blank", [validation: :required]},
               password: {"can't be blank", [validation: :required]}
             ]
    end
  end

  describe "get_by/2" do
    test "returns a user when finding by email" do
      email = "john.doe@test.com"
      {:ok, user} = Users.create(%{email: email, password: "123456"})

      {:ok, get_by_user} = Users.get_by(:email, email)

      assert get_by_user.id == user.id
      assert get_by_user.email == user.email
    end

    test "returns nil if the user can not be found" do
      assert Users.get_by(:email, "john.doe@test.com") == {:error, :not_found}
    end

    test "raises an error when querying by an unknown field" do
      assert_raise(Ecto.QueryError, fn ->
        Users.get_by(:unknown, "john.doe@test.com")
      end)
    end
  end

  describe "encrypt_password/1" do
    test "returns an encrypted password" do
      password = "123456"

      assert "$argon2id$v=19$m=256,t=1,p=4$" <> _hash = Users.encrypt_password(password)
    end
  end

  describe "verify_password/2" do
    test "returns true when password matches" do
      password = "123456"
      {:ok, user} = Users.create(%{email: "john.doe@test.com", password: password})

      assert Users.verify_password(user, password)
    end

    test "returns false when password does not match" do
      {:ok, user} = Users.create(%{email: "john.doe@test.com", password: "123456"})

      refute Users.verify_password(user, "wrong_pass")
    end

    test "returns false when user is nil" do
      refute Users.verify_password(nil, "pass")
    end
  end
end
