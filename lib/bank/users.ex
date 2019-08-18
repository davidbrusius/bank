defmodule Bank.Users do
  @moduledoc """
  Functions for dealing with Bank.Users.User resource.
  """

  import Ecto.Query

  alias Bank.Repo
  alias Bank.Users.User

  @spec create(map()) :: {:ok, User.t()} | {:error, %Ecto.Changeset{}}
  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec get_by(atom(), any()) :: {:ok, User.t()} | {:error, atom()}
  def get_by(field, value) do
    query = from u in User, where: field(u, ^field) == ^value

    case Repo.one(query) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  defdelegate encrypt_password(password), to: Bank.Users.Password
  defdelegate verify_password(user, password), to: Bank.Users.Password
end
