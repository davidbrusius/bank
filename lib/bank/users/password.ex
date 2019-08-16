defmodule Bank.Users.Password do
  @moduledoc false

  @type password :: String.t()
  @type encrypted_password :: String.t()

  @spec encrypt_password(password()) :: encrypted_password()
  def encrypt_password(password) do
    Argon2.hash_pwd_salt(password)
  end

  @spec verify_password(User.t() | nil, password()) :: boolean()
  def verify_password(user, password) when not is_nil(user) do
    Argon2.verify_pass(password, user.password_hash)
  end

  # Protect against time based attacks while trying to verify a user password
  def verify_password(nil, _password) do
    Argon2.no_user_verify()
  end
end
