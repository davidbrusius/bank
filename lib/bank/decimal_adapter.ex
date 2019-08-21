defmodule Bank.DecimalAdapter do
  @moduledoc """
  Decimal adapter to convert numbers to the required format they are stored in the database.
  """

  @doc """
  Money values are represented as cents in the database, therefore we need to convert numbers
  from decimal to integer cents. Maximum precision allowed for numbers is 2 decimal places, so
  we round the numbers to make sure they only have 2 decimal places, if a number has more than
  2 decimal places they will be ignored as per rounding down strategy.

  ## Examples:

      iex> to_storage(25)
      2500
      iex> to_storage(25.50)
      2550
      iex> to_storage("29.999")
      2999

  """
  @spec to_storage(number() | String.t()) :: integer()
  def to_storage(number) do
    number
    |> Decimal.cast()
    |> Decimal.round(2, :down)
    |> Decimal.mult(100)
    |> Decimal.to_integer()
  end
end
