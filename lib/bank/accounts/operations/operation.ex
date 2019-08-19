defmodule Bank.Account.Operation do
  @moduledoc false

  @callback prepare(map()) :: Ecto.Multi.t()
end
