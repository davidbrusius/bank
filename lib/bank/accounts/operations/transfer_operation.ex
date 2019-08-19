defmodule Bank.Accounts.TransferOperation do
  @moduledoc false

  @behaviour Bank.Account.Operation

  alias Bank.Accounts.{DepositOperation, TransferValidator, WithdrawOperation}
  alias Ecto.Multi

  @spec prepare(any) :: Ecto.Multi.t()
  def prepare(transfer) do
    Multi.new()
    |> Multi.run(:validate_transfer, fn _, _ -> TransferValidator.validate(transfer) end)
    |> Multi.merge(fn _ ->
      WithdrawOperation.prepare(%{account: transfer.source_account, amount: transfer.amount})
    end)
    |> Multi.merge(fn _ ->
      DepositOperation.prepare(%{account: transfer.dest_account, amount: transfer.amount})
    end)
  end
end
