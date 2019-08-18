defmodule Bank.Auth.Token do
  @moduledoc """
  Provides functions for generating and verifying authorization tokens.
  """

  @auth_token_salt "auth_token_salt"
  @max_age 86_400

  @type auth_token :: String.t()

  @doc """
  Generates an authorization token for a given user id. The user id value will be encoded
  in the token to allow reading it while verifying the token.

  Returns a string.
  """
  @spec generate_auth_token(binary()) :: auth_token()
  def generate_auth_token(user_id) do
    Phoenix.Token.sign(BankWeb.Endpoint, @auth_token_salt, user_id)
  end

  @doc """
  Verifies an authorization token and returns the user id stored on it.

    * If the token can be verified successfully, it returns a success tuple containing
    the decoded user id ({:ok, "user_id"}).
    * If the token is expired, it returns an error tuple ({:error, :expired}).
    * If the token is invalid and therefore can not be verified, it returns an error
    tuple ({:error, :invalid}).

  Returns a tuple.
  """
  @spec verify_auth_token(auth_token(), integer()) :: {:ok, binary()} | {:error, atom()}
  def verify_auth_token(token, max_age \\ @max_age) do
    Phoenix.Token.verify(BankWeb.Endpoint, @auth_token_salt, token, max_age: max_age)
  end
end
