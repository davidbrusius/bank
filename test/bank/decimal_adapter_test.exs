defmodule Bank.DecimalAdapterTest do
  use ExUnit.Case, async: true

  doctest Bank.DecimalAdapter, import: true

  alias Bank.DecimalAdapter

  describe "to_storage/1" do
    test "converts numbers to integer cents" do
      assert DecimalAdapter.to_storage(1) == 100
      assert DecimalAdapter.to_storage(10) == 1000
      assert DecimalAdapter.to_storage(10.50) == 1050
      assert DecimalAdapter.to_storage(999.99) == 99_999
    end

    test "converts strings to integer cents" do
      assert DecimalAdapter.to_storage("1") == 100
      assert DecimalAdapter.to_storage("10") == 1000
      assert DecimalAdapter.to_storage("10.50") == 1050
      assert DecimalAdapter.to_storage("999.99") == 99_999
    end

    test "rounds down numbers with more than 2 decimal places" do
      assert DecimalAdapter.to_storage(10.2411) == 1024
      assert DecimalAdapter.to_storage(10.2455) == 1024
      assert DecimalAdapter.to_storage(10.2499) == 1024
    end
  end
end
