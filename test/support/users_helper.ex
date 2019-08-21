defmodule Bank.UsersHelper do
  @moduledoc false

  alias Bank.{Users, Users.User}

  @user_attrs %{email: "john.doe@test.com", password: "123456"}

  def create_user(attrs \\ %{}) do
    attrs = Map.merge(@user_attrs, attrs)
    {:ok, %User{} = user} = Users.create(attrs)
    user
  end
end
