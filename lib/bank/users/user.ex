defmodule Bank.Users.User do
  @moduledoc false

  use Bank.Schema
  import Ecto.Changeset

  alias Bank.Users

  @type t :: %__MODULE__{
          id: binary(),
          email: String.t(),
          password_hash: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    timestamps()
  end

  @required_attrs [:email, :password]

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_email(:email)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @email_format ~r/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  defp validate_email(changeset, field) do
    validate_format(changeset, field, @email_format)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    password_hash = Users.encrypt_password(password)
    change(changeset, password_hash: password_hash)
  end

  defp put_password_hash(changeset), do: changeset
end
