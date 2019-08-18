defmodule Bank.Auth do
  @moduledoc """
  Functions related to API authentication.
  """

  alias Bank.{Users, Users.User}

  @spec authenticate_user(map()) :: {:ok, User.t()} | :error
  def authenticate_user(%{email: email, password: password}) do
    with {:ok, user} <- Users.get_by(:email, email),
         true <- Users.verify_password(user, password) do
      {:ok, user}
    else
      _ ->
        :error
    end
  end

  defdelegate generate_auth_token(user_id), to: Bank.Auth.Token
  defdelegate verify_auth_token(token), to: Bank.Auth.Token
  defdelegate verify_auth_token(token, max_age), to: Bank.Auth.Token
end
