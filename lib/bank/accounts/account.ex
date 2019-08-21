defmodule Bank.Accounts.Account do
  @moduledoc false

  use Bank.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: binary(),
          user: Bank.Users.User.t() | %Ecto.Association.NotLoaded{},
          transactions: [Bank.Accounts.Transaction.t()] | %Ecto.Association.NotLoaded{},
          number: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "accounts" do
    belongs_to :user, Bank.Users.User
    has_many :transactions, Bank.Accounts.Transaction

    field :balance, Money.Ecto.Amount.Type, default: Money.new(0)
    field :number, :string
    timestamps()
  end

  @required_attrs [:number]
  @optional_attrs [:balance]

  def changeset(account, attrs) do
    account
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:number)
  end

  def changeset(account, user, attrs) do
    account
    |> changeset(attrs)
    |> put_assoc(:user, user)
    |> validate_required([:user])
  end
end
